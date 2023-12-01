//
//  SocketState.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 2/12/23.
//

import Foundation
import Network

enum SocketState {
    /// The socket is not currently in an active connection state.
    case notReady

    /// The socket is in an established state with specific connection details.
    ///
    /// - Parameters:
    ///   - host: The host to which the socket is connected.
    ///   - port: The port on the host to which the socket is connected.
    ///   - connection: The underlying `NWConnection` object representing the socket connection.
    case established(ConnectionDetails)

    /// A structure holding connection details.
    ///
    /// - Parameters:
    ///   - host: The host to which the socket is connected.
    ///   - port: The port on the host to which the socket is connected.
    ///   - connection: The underlying `NWConnection` object representing the socket connection.
    struct ConnectionDetails {
        /// The host to which the socket is connected.
        let host: String

        /// The port on the host to which the socket is connected.
        let port: UInt16

        /// The underlying `NWConnection` object representing the socket connection.
        let nwConnection: NWConnection
    }
}
