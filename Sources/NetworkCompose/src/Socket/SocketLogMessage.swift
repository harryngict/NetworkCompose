//
//  SocketLogMessage.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 2/12/23.
//

import Foundation
import Network

public enum SocketLogMessage {
    case notEstablishedConnection
    case didReceiveWithError(NWError)
    case isWaitingWithError(NWError)
    case connectFailedWithError(NWError)
    case invalidState(NWConnection.State)
    case didSendWithError(NWError)
    case dataWritingIsEmpty
    case trustedConnection(host: String)
    case untrustedConnection(host: String)

    var message: String {
        switch self {
        case .notEstablishedConnection: return "Socket does not have an established connection."
        case let .didReceiveWithError(error): return "Socket did receive with error: \(error)"
        case let .isWaitingWithError(error): return "Socket is waiting with error: \(error)"
        case let .connectFailedWithError(error): return "Socket connect failed with error: \(error)"
        case let .invalidState(state): return "Socket invalid state: \(state)"
        case let .didSendWithError(error): return "Socket did send with error:: \(error)"
        case .dataWritingIsEmpty: return "Socket data writing isEmpty."
        case let .trustedConnection(host): return "Socket trust: \(host)"
        case let .untrustedConnection(host): return "Socket does not trust: \(host)"
        }
    }
}
