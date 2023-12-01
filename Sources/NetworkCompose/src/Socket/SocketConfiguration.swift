//
//  SocketConfiguration.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 2/12/23.
//

import Foundation
import Network

public struct SocketConfiguration {
    /// SSL pinning policy for the socket connection. Default is `.disabled`.
    public let sslPinningPolicy: SSLPinningPolicy

    /// The type of connection for the socket. Default is `.udp`.
    public let socketType: SocketType

    /// The maximum length for data when receiving. Default is `65536`.
    public let maximumLength: UInt64

    /// The minimum length for incomplete data when receiving. Default is `1`.
    public let minimumIncompleteLength: UInt64

    /// Initializes a new `SocketConnectionConfiguration` instance.
    ///
    /// - Parameters:
    ///   - socketType: The type of connection for the socket. Default is `.udp`.
    ///   - maximumLength: The maximum length for data when receiving. Default is `65536`.
    ///   - minimumIncompleteLength: The minimum length for incomplete data when receiving. Default is `1`.
    ///   - sslPinningPolicy: SSL pinning policy for the socket connection. Default is `.disabled`.
    public init(socketType: SocketType = .udp,
                maximumLength: UInt64 = 65536,
                minimumIncompleteLength: UInt64 = 1,
                sslPinningPolicy: SSLPinningPolicy = .disabled)
    {
        self.socketType = socketType
        self.maximumLength = maximumLength
        self.minimumIncompleteLength = minimumIncompleteLength
        self.sslPinningPolicy = sslPinningPolicy
    }

    /// An enum representing the type of connection for the socket.
    public enum SocketType {
        /// TCP connection type with an optional connection timeout.
        case tcp(timeout: TimeInterval?)

        /// UDP connection type.
        case udp

        /// Provides parameters for the given connection type and TLS options.
        ///
        /// - Parameter options: The TLS options for the connection.
        /// - Returns: The network parameters for the connection type.
        public func parameters(options: NWProtocolTLS.Options) -> NWParameters {
            switch self {
            case let .tcp(timeout):
                guard let timeout = timeout else {
                    return NWParameters(tls: options)
                }
                let tcpOptions = NWProtocolTCP.Options()
                tcpOptions.connectionTimeout = Int(timeout)
                return NWParameters(tls: options, tcp: tcpOptions)
            case .udp:
                return NWParameters(dtls: options, udp: NWProtocolUDP.Options())
            }
        }
    }
}
