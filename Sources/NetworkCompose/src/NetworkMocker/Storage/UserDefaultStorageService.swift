//
//  UserDefaultStorageService.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 26/11/23.
//

import Foundation

protocol KeyValueStorage {
    func set(_ value: Any?, forKey defaultName: String)
    func object(forKey defaultName: String) -> Any?
    func synchronize() -> Bool
}

extension UserDefaults: KeyValueStorage {}

final class UserDefaultStorageService: StorageService {
    private let service: KeyValueStorage

    init(service: KeyValueStorage = UserDefaults.standard) {
        self.service = service
    }

    func storeResponse<RequestType>(
        _ request: RequestType,
        data: Data,
        model _: RequestType.SuccessType
    ) throws where RequestType: RequestInterface {
        let key = UniqueKeyPath(path: request.path,
                                method: request.method.rawValue).key
        service.set(data, forKey: key)
        _ = service.synchronize()
    }

    func getResponse<RequestType>(
        _ request: RequestType
    ) throws -> RequestType.SuccessType where RequestType: RequestInterface {
        let key = UniqueKeyPath(path: request.path,
                                method: request.method.rawValue).key
        if let data = service.object(forKey: key) as? Data {
            do {
                let model = try request.responseDecoder.decode(RequestType.SuccessType.self, from: data)
                return model
            } catch {
                throw NetworkError.decodingFailed(modeType: String(describing: RequestType.SuccessType.self),
                                                  context: error.localizedDescription)
            }
        }
        throw NetworkError.invalidResponse
    }
}
