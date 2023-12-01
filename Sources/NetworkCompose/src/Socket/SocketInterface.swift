//
//  SocketInterface.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 2/12/23.
//

import Foundation

public protocol SocketInterface {
    /// A boolean value indicating whether the socket is currently connected.
    var isConnected: Bool { get }

    /// The delegate for handling socket events. Set to `nil` if no delegate is assigned.
    var delegate: SocketDelegate? { get set }

    /// Disconnects the socket connection.
    func disconnect()

    /// Connects the socket to a specified host and port.
    ///
    /// - Parameters:
    ///   - host: The host to connect to.
    ///   - port: The port on which to connect.
    /// - Throws: An error of type `SocketError` if the connection cannot be established.
    func connect(toHost host: String, onPort port: UInt16) throws

    /// Initiates reading data from the socket with a specified tag for identification.
    ///
    /// - Parameter tag: A String tag to identify the read operation.
    func readData(withTag tag: String)

    /// Writes data to the socket connection with a specified tag for identification.
    ///
    /// - Parameters:
    ///   - data: The data to be written to the socket connection.
    ///   - tag: A String tag to identify the write operation.
    func write(data: Data, withTag tag: String)
}
