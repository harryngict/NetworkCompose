//
//  Socket.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 2/12/23.
//

import Foundation
import Network

/// A class representing a socket connection that conforms to the `SocketInterface`.
public final class Socket: SocketInterface {
    /// A boolean value indicating whether the socket connection is currently connected.
    public var isConnected: Bool = false

    /// The delegate for handling socket connection events. Set to `nil` if no delegate is assigned.
    public weak var delegate: SocketDelegate?

    /// The configuration for the socket connection.
    private let configuration: SocketConfiguration

    /// The dispatch queue for socket connection-related operations.
    private let queue: DispatchQueue

    /// The dispatch queue for delegate callbacks. If `nil`, callbacks are executed on the socket connection queue.
    private var delegateQueue: DispatchQueue?

    /// The current state of the socket connection.
    private var connectionState = SocketState.notReady

    /// The logger used for logging socket connection-related events.
    private var logger: LoggerInterface?

    /// Initializes a new socket connection instance.
    ///
    /// - Parameters:
    ///   - configuration: The configuration for the socket connection.
    ///   - queue: The dispatch queue for socket connection-related operations.
    ///   - delegate: The delegate for handling socket connection events.
    ///   - delegateQueue: The dispatch queue for delegate callbacks. If `nil`, callbacks are executed on the socket connection queue.
    ///   - loggerStrategy: The logging strategy for the socket connection.
    public init(
        configuration: SocketConfiguration = SocketConfiguration(),
        queue: DispatchQueue = DispatchQueue(label: "\(LibraryConstant.domain).Socket"),
        delegate: SocketDelegate? = nil,
        delegateQueue: DispatchQueue? = nil,
        loggerStrategy: LoggerStrategy = .disabled
    ) {
        self.configuration = configuration
        self.queue = queue
        self.delegate = delegate
        self.delegateQueue = delegateQueue
        logger = getLogger(loggerStrategy)
    }

    /// Disconnects the socket.
    public func disconnect() {
        guard case let .established(state) = connectionState else {
            logger?.log(.error, SocketLogMessage.notEstablishedConnection.message)
            return
        }

        state.nwConnection.stateUpdateHandler = nil
        state.nwConnection.cancel()
        isConnected = false
        connectionState = .notReady

        asyncDelegateAction { delegate in
            delegate.didDisconnect(self)
        }
    }

    /// Connects the socket connection to a specified host and port with an optional timeout.
    ///
    /// - Parameters:
    ///   - host: The host to connect to.
    ///   - port: The port on which to connect.
    /// - Throws: An error of type `SocketError` if the connection cannot be established.
    public func connect(
        toHost host: String,
        onPort port: UInt16
    ) throws {
        guard let nwPort = NWEndpoint.Port("\(port)") else {
            throw SocketError.invalidPort
        }
        let params = getNWParameters(sslPinningPolicy: configuration.sslPinningPolicy,
                                     protectionHot: host,
                                     queue: queue)
        let nwConnection = NWConnection(
            host: NWEndpoint.Host(host),
            port: nwPort,
            using: params
        )
        connectionState = .established(SocketState.ConnectionDetails(host: host,
                                                                     port: port,
                                                                     nwConnection: nwConnection))
        nwConnection.stateUpdateHandler = didChange(state:)
        nwConnection.start(queue: queue)
    }

    public func readData(withTag tag: String) {
        guard case let .established(state) = connectionState else {
            logger?.log(.error, SocketLogMessage.notEstablishedConnection.message)
            return
        }
        state.nwConnection.receive(minimumIncompleteLength: Int(configuration.minimumIncompleteLength),
                                   maximumLength: Int(configuration.minimumIncompleteLength))
        { data, _, isComplete, error in
            if let data = data {
                self.asyncDelegateAction { $0.didReceive(self, data: data) }
            }

            if isComplete {
                self.disconnect()
            } else if let error = error {
                self.delegate?.didConnect(self, withError: error, withTag: tag)
            } else {
                self.readData(withTag: tag)
            }
        }
    }

    public func write(data: Data, withTag tag: String) {
        guard !data.isEmpty else {
            logger?.log(.error, SocketLogMessage.dataWritingIsEmpty.message)
            return
        }

        guard case let .established(state) = connectionState else {
            logger?.log(.error, SocketLogMessage.notEstablishedConnection.message)
            return
        }
        let sizePrefix = withUnsafeBytes(of: UInt16(data.count).bigEndian) { Data($0) }

        state.nwConnection.batch {
            state.nwConnection.send(content: sizePrefix, completion: .contentProcessed { error in
                if let error = error {
                    self.delegate?.didConnect(self, withError: error, withTag: tag)
                    return
                }
            })

            state.nwConnection.send(content: data, completion: .contentProcessed { error in
                if let error = error {
                    self.delegate?.didConnect(self, withError: error, withTag: tag)
                    return
                }
            })
        }
    }
}

private extension Socket {
    func didChange(state: NWConnection.State) {
        switch state {
        case .setup, .preparing:
            break
        case let .waiting(error):
            logger?.log(.error, SocketLogMessage.isWaitingWithError(error).message)
        case .ready:
            handleReadyState()
        case let .failed(error):
            logger?.log(.error, SocketLogMessage.connectFailedWithError(error).message)
            disconnect()
        case .cancelled:
            disconnect()
        @unknown default:
            let message = SocketLogMessage.invalidState(state).message
            logger?.log(.error, message)
            assertionFailure(message)
        }
    }

    func handleReadyState() {
        guard case let .established(state) = connectionState else {
            let message = SocketLogMessage.notEstablishedConnection.message
            logger?.log(.error, message)
            assertionFailure(message)
            return
        }

        isConnected = true
        asyncDelegateAction { delegate in
            delegate.didReady(self, host: state.host, port: state.port)
        }
    }

    func asyncDelegateAction(
        _ action: @escaping (_ delegate: SocketDelegate) -> Void
    ) {
        guard let delegate = delegate else {
            return
        }

        if let delegateQueue = delegateQueue {
            delegateQueue.async {
                action(delegate)
            }
        } else {
            queue.async {
                action(delegate)
            }
        }
    }

    func getLogger(
        _ strategy: LoggerStrategy
    ) -> LoggerInterface? {
        switch strategy {
        case .disabled:
            return nil
        case .enabled:
            return DefaultLogger.shared
        case let .custom(logger):
            return logger
        }
    }
}

// MARK: SecTrustEvaluate

private extension Socket {
    func getNWParameters(
        sslPinningPolicy: SSLPinningPolicy,
        protectionHot: String,
        queue: DispatchQueue
    ) -> NWParameters {
        let options = NWProtocolTLS.Options()

        guard case let .trust(sslPinnings) = sslPinningPolicy else {
            return configuration.socketType.parameters(options: options)
        }

        sec_protocol_options_set_verify_block(
            options.securityProtocolOptions,
            { [weak self] _, secTrust, secVerifyComplete in
                guard let self = self else {
                    secVerifyComplete(true)
                    return
                }
                let trust = sec_trust_copy_ref(secTrust).takeRetainedValue()
                var error: CFError?
                if SecTrustEvaluateWithError(trust, &error) {
                    self.handleTrustEvaluation(protectionHot,
                                               trust,
                                               sslPinnings,
                                               secVerifyComplete)
                } else {
                    secVerifyComplete(false)
                }
            },
            queue
        )

        return configuration.socketType.parameters(options: options)
    }

    func handleTrustEvaluation(
        _ protectionHot: String,
        _ serverTrust: SecTrust,
        _ sslPinnings: [SSLPinningInterface],
        _ secVerifyComplete: @escaping (Bool) -> Void
    ) {
        let policies: [SecPolicy] = [SecPolicyCreateSSL(true, protectionHot as CFString?)]
        SecTrustSetPolicies(serverTrust, policies as CFTypeRef)

        var result = SecTrustResultType.invalid
        SecTrustEvaluate(serverTrust, &result)

        guard SecTrustGetCertificateCount(serverTrust) > 0 else {
            secVerifyComplete(false)
            return
        }

        guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            secVerifyComplete(false)
            return
        }

        guard let serverKey = certificate.publicKey?.publicKeyData else {
            secVerifyComplete(false)
            return
        }

        let hash = serverKey.addRSAHeader()

        if let sslPinning = sslPinnings.first(where: { $0.host == protectionHot }), sslPinning.hashKeys.contains(hash) {
            logger?.log(.debug, SocketLogMessage.trustedConnection(host: protectionHot).message)
            secVerifyComplete(true)
        } else {
            logger?.log(.debug, SocketLogMessage.untrustedConnection(host: protectionHot).message)
            secVerifyComplete(false)
        }
    }
}
