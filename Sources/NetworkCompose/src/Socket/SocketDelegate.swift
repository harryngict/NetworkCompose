//
//  SocketDelegate.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 2/12/23.
//

import Foundation

/// A protocol defining the delegate methods for handling socket connection events.
public protocol SocketDelegate: AnyObject {
    /// Notifies the delegate when the socket has successfully connected.
    ///
    /// - Parameters:
    ///   - connection: The socket connection that has successfully connected.
    ///   - host: The host to which the socket connected.
    ///   - port: The port on which the socket connected.
    func didReady(_ socket: SocketInterface, host: String, port: UInt16)

    /// Notifies the delegate when data is received on the socket.
    ///
    /// - Parameters:
    ///   - connection: The socket connection that received data.
    ///   - data: The data received on the socket.
    func didReceive(_ socket: SocketInterface, data: Data)

    /// Notifies the delegate when the socket connection is disconnected.
    ///
    /// - Parameters:
    ///   - connection: The socket connection that was disconnected.
    func didDisconnect(_ socket: SocketInterface)

    /// Notifies the delegate when an attempt to connect the socket resulted in an error.
    ///
    /// - Parameters:
    ///   - connection: The socket connection that encountered an error during connection.
    ///   - error: The error that occurred during the connection attempt.
    ///   - tag: A String tag to identify the write operation.
    func didConnect(_ socket: SocketInterface, withError error: Error?, withTag: String)
}
