//
//  FileSystemStorageService.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 26/11/23.
//

import Foundation

protocol FileStorage {
    func urls(for directory: FileManager.SearchPathDirectory,
              in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func fileExists(atPath path: String) -> Bool
    func createDirectory(at url: URL,
                         withIntermediateDirectories createIntermediates: Bool,
                         attributes: [FileAttributeKey: Any]?) throws
    func contentsOfDirectory(atPath path: String) throws -> [String]
    func removeItem(atPath path: String) throws
}

extension FileManager: FileStorage {}

final class FileSystemStorageService: StorageServiceInterface {
    private let service: FileStorage
    private let executionQueue: DispatchQueueType

    init(service: FileStorage = FileManager.default,
         executionQueue: DispatchQueueType)
    {
        self.service = service
        self.executionQueue = executionQueue
    }

    private lazy var homeURL: URL = {
        var directory = service.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        directory.appendPathComponent("\(Constant.homeDirectoryTitle)/")
        return directory
    }()

    func storeResponse<RequestType>(
        _ request: RequestType,
        data: Data,
        model _: RequestType.SuccessType
    ) throws where RequestType: RequestInterface {
        let path = UniqueKey(request: request).key
        try storeDataToFile(data, forPath: path)
    }

    func getResponse<RequestType>(
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: RequestInterface {
        let path = UniqueKey(request: request).key
        let data = try getDataFromFile(atPath: path)
        do {
            let model = try request.responseDecoder.decode(RequestType.SuccessType.self,
                                                           from: data)
            return model
        } catch {
            throw NetworkError.invalidResponse
        }
    }

    func clearMockDataInDisk() throws {
        let path = homeURL.path
        let files = try service.contentsOfDirectory(atPath: path)

        for file in files {
            let filePath = URL(fileURLWithPath: path).appendingPathComponent(file).path
            try service.removeItem(atPath: filePath)
        }
    }
}

private extension FileSystemStorageService {
    enum Constant {
        static let homeDirectoryTitle: String = "NetworkCompose-FileSystemStorageService"
    }

    func hasHomeDirectory() throws -> Bool {
        guard service.fileExists(atPath: homeURL.path) == false else {
            return true
        }
        try service.createDirectory(at: homeURL, withIntermediateDirectories: true, attributes: nil)
        return true
    }

    func storeDataToFile(
        _ data: Data,
        forPath path: String
    ) throws {
        guard try hasHomeDirectory() else {
            throw NetworkError.automation(.notFoundHomeDirectory)
        }
        try data.write(to: homeURL.appendingPathComponent(path))
    }

    private func getDataFromFile(atPath path: String) throws -> Data {
        guard try hasHomeDirectory() else {
            throw NetworkError.automation(.notFoundHomeDirectory)
        }
        let data = try Data(contentsOf: homeURL.appendingPathComponent(path))
        return data
    }
}
