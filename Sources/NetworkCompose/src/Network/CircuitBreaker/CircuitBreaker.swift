//
//  CircuitBreaker.swift
//  NetworkCompose
//
//  Created by Hoang Nguyezn on 16/1/24.
//

import Foundation

public final class CircuitBreaker {
    /// A typealias for the completion block used in network operations.
    public typealias TaskCompletion<T> = (@escaping (Result<T, NetworkError>) -> Void) -> Void

    /// A typealias for the circuit breaker state change event.
    public typealias CircuitBreakerEvent = (CircuitBreaker) -> Void

    /// The current state of the circuit breaker.
    private var state: CircuitBreakerState = .closed

    /// The count of consecutive failures.
    private var failureCount = 0

    /// The maximum allowed consecutive failures before opening the circuit.
    private let maxFailures: Int

    /// The duration to keep the circuit open before attempting to half-open.
    private let resetTimeout: TimeInterval

    /// The DispatchQueue for handling circuit breaker events.
    private let eventQueue = DispatchQueue(label: "CircuitBreakerEventQueue")

    /// The timestamp when the circuit was last opened.
    private var openTimestamp: Date?

    /// A closure to be executed when the circuit breaker state changes.
    public var onStateChange: CircuitBreakerEvent?

    /// Initializes a new instance of `CircuitBreaker`.
    ///
    /// - Parameters:
    ///   - maxFailures: The maximum allowed consecutive failures before opening the circuit.
    ///   - resetTimeout: The duration to keep the circuit open before attempting to half-open.
    public init(maxFailures: Int, resetTimeout: TimeInterval) {
        self.maxFailures = maxFailures
        self.resetTimeout = resetTimeout
    }

    /// Executes the provided asynchronous operation, handling circuit breaker logic.
    ///
    /// - Parameters:
    ///   - operation: The asynchronous operation to execute.
    func run<T>(_ operation: @escaping TaskCompletion<T>) {
        guard state != .open else {
            handleOpenState()
            return
        }

        operation { [weak self] result in
            switch result {
            case .success:
                self?.handleSuccess()
            case let .failure(error):
                self?.handleFailure(error)
            }
        }
    }

    private func handleSuccess() {
        resetFailureCount()
        closeCircuitIfNeeded()
    }

    private func handleFailure(_: Error) {
        failureCount += 1
        openCircuitIfNeeded()
    }

    private func handleOpenState() {
        guard let openTimestamp = openTimestamp else {
            openCircuit()
            return
        }

        if Date().timeIntervalSince(openTimestamp) >= resetTimeout {
            halfOpenCircuit()
        }
    }

    private func openCircuitIfNeeded() {
        if failureCount >= maxFailures {
            openCircuit()
        }
    }

    private func closeCircuitIfNeeded() {
        if state == .halfOpen {
            closeCircuit()
        }
    }

    private func openCircuit() {
        state = .open
        openTimestamp = Date()
        notifyStateChange()
    }

    private func closeCircuit() {
        state = .closed
        resetFailureCount()
        notifyStateChange()
    }

    private func halfOpenCircuit() {
        state = .halfOpen
        resetFailureCount()
        notifyStateChange()
    }

    private func resetFailureCount() {
        failureCount = 0
    }

    private func notifyStateChange() {
        eventQueue.async { [weak self] in
            self?.onStateChange?(self!)
        }
    }
}
