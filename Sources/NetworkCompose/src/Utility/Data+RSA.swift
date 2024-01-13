//
//  Data+RSA.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 22/11/23.
//

import CommonCrypto
import Foundation

extension Data {
    func addRSAHeader() -> String {
        let header: [UInt8] = [0x30, 0x82, 0x01, 0x22, 0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86,
                               0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0F, 0x00]

        var dataWithHeader = Data(header)
        dataWithHeader.append(self)

        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        dataWithHeader.withUnsafeBytes { bufferPointer in
            _ = CC_SHA256(bufferPointer.baseAddress, CC_LONG(dataWithHeader.count), &hash)
        }

        return Data(hash).base64EncodedString()
    }
}
