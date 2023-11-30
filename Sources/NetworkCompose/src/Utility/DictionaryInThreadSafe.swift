//
//  DictionaryInThreadSafe.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 30/11/23.
//

import Foundation

/// A thread-safe wrapper around a dictionary, providing concurrent access and modification.
///
/// This class ensures thread safety for read and write operations on an underlying dictionary
/// by using a concurrent queue for synchronization.
public final class DictionaryInThreadSafe<Key: Hashable, Value> {
    /// The underlying dictionary protected by a concurrent queue.
    private var threadUnsafeDict: [Key: Value]

    /// A concurrent queue to synchronize access to the underlying dictionary.
    private let concurrentQueue = DispatchQueue(label: "com.NetworkCompose.DictionaryInThreadSafe", attributes: .concurrent)

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
    /// The starting index of the dictionary.
    public var startIndex: Dictionary<Key, Value>.Index {
        concurrentQueue.sync { self.threadUnsafeDict.startIndex }
    }

    /// The ending index of the dictionary.
    public var endIndex: Dictionary<Key, Value>.Index {
        concurrentQueue.sync { self.threadUnsafeDict.endIndex }
    }

    /// Accesses the key-value pair at the specified position.
    ///
    /// - Parameter index: The position of the key-value pair to retrieve.
    public subscript(index: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Element {
        concurrentQueue.sync { self.threadUnsafeDict[index] }
    }

    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: The index to advance from.
    /// - Returns: The index immediately after `i`.
    public func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        concurrentQueue.sync { self.threadUnsafeDict.index(after: i) }
    }
}
