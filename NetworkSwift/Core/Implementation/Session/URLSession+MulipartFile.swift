//
//  URLSession+MulipartFile.swift
//  NetworkSwift/Core
//
//  Created by Hoang Nguyen on 22/11/23.
//

import Foundation

/// An extension on URLSession to facilitate the creation of a URLRequest with multipart form data for an upload task.
extension URLSession {
    /// Creates a URLRequest with multipart form data for the upload task.
    ///
    /// - Parameters:
    ///   - request: The inout URLRequest for the network request.
    ///   - fileURL: The file URL to upload.
    /// - Throws: A NetworkError in case of failure.
    /// - Returns: A URLRequest with multipart form data.
    ///
    /// Example:
    /// ```swift
    /// var uploadRequest = URLRequest(url: uploadURL)
    /// do {
    ///     try URLSession.shared.createMultipartFileRequest(&uploadRequest, fromFile: fileURL)
    /// } catch {
    ///     print("Error creating multipart file request: \(error)")
    /// }
    /// ```
    func createMultipartFileRequest(
        _ request: inout URLRequest,
        fromFile fileURL: URL
    ) throws -> URLRequest {
        let boundary = UUID().uuidString
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        let bodyStream = InputStream(url: fileURL)
        request.httpBodyStream = bodyStream
        return request
    }
}
