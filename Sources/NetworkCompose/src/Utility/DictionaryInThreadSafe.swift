//
//  DictionaryInThreadSafe.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 30/11/23.
//

import Foundation

public final class DictionaryInThreadSafe<Key: Hashable, Value> {
    private var threadUnsafeDict: [Key: Value]
    private let concurrentQueue = DispatchQueue(label: "\(LibraryConstant.domain).DictionaryInThreadSafe",
                                                attributes: .concurrent)

    /// Initializes a new instance of `DictionaryInThreadSafe` with an optional initial dictionary.
    ///
    /// - Parameter dict: An optional initial dictionary. Default is an empty dictionary.
    public init(dict: [Key: Value] = [:]) {
        threadUnsafeDict = dict
    }

    /// Accesses the value associated with the given key for reading and writing in a thread-safe manner.
    ///
    /// - Parameter key: The key to look up in the dictionary.
    /// - Returns: The current value associated with the key, or `nil` if the key is not present.
    public subscript(key: Key) -> Value? {
        set(newValue) {
            concurrentQueue.async(flags: .barrier) { [weak self] in
                self?.threadUnsafeDict[key] = newValue
            }
        }
        get {
            concurrentQueue.sync { self.threadUnsafeDict[key] }
        }
    }

    /// Removes the value associated with the specified key in a thread-safe manner.
    ///
    /// - Parameter key: The key to remove from the dictionary.
    public func removeValue(forKey key: Key) {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            self?.threadUnsafeDict.removeValue(forKey: key)
        }
    }
}

// MARK: - Collection

extension DictionaryInThreadSafe: Collection {
    public var startIndex: Dictionary<Key, Value>.Index {
        concurrentQueue.sync { self.threadUnsafeDict.startIndex }
    }

    public var endIndex: Dictionary<Key, Value>.Index {
        concurrentQueue.sync { self.threadUnsafeDict.endIndex }
    }

    public subscript(index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        concurrentQueue.sync { self.threadUnsafeDict[index] }
    }

    public func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        concurrentQueue.sync { self.threadUnsafeDict.index(after: i) }
    }
}
