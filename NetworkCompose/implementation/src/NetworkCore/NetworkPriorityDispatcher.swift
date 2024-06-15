//
//  NetworkPriorityDispatcher.swift
//  NetworkComposeImp
//
//  Created by Hoang Nguyezn on 28/11/23.
//

import Foundation
import NetworkCompose

// MARK: - NetworkPriorityDispatcher

public final class NetworkPriorityDispatcher<SessionType: NetworkSession>: NetworkBuilder<SessionType> {
  // MARK: Public

  /// Adds a request to the network composition with the specified priority.
  ///
  /// - Parameters:
  ///   - request: The request to be executed.
  ///   - headers: The headers to be included in the request.
  ///   - retryPolicy: The retry policy for the request.
  ///   - priority: The priority of the request.
  ///   - completion: A closure to be called upon completion of the request.
  /// - Returns: The instance of `NetworkCompose` to allow method chaining.
  @discardableResult
  public func addRequest<RequestType: RequestInterface, ResultType>(_ request: RequestType,
                                                                    andHeaders headers: [String: String] = [:],
                                                                    retryPolicy: RetryPolicy = .disabled,
                                                                    priority: Priority = .medium,
                                                                    completion: @escaping (Result<ResultType, NetworkError>) -> Void)
    -> Self where RequestType.SuccessType == ResultType
  {
    addAction(priority: priority) { [weak self] actionCompletion in
      self?.build().request(
        request,
        andHeaders: headers,
        retryPolicy: retryPolicy)
      { requestResult in
        completion(requestResult.map { $0 as ResultType })
        actionCompletion(requestResult.map { $0 as ResultType })
      }
    }
    return self
  }

  /// Cancels a network request with the specified type asynchronously.
  ///
  /// - Parameters:
  ///   - request: The network request to cancel.
  ///   - priority: The priority of the cancellation action. Default is `.medium`.
  /// - Returns: An instance of `Self` for method chaining.
  /// - Note: The cancellation action is executed based on the specified priority.
  public func cancelRequest(_ request: some RequestInterface,
                            priority: Priority = .medium)
    -> Self
  {
    addAction(priority: priority) { [weak self] actionCompletion in
      self?.build().cancelRequest(request)
      actionCompletion(())
    }
    return self
  }

  /// Executes the composed network actions.
  ///
  /// - Parameter completion: A closure to be called upon completion of all network actions.
  public func execute(completion: (() -> Void)? = nil) {
    guard totalNumberOfActions > 0 else {
      completion?()
      return
    }
    allActionsCompletion = completion
    var remainingActions = priorityActions.sorted()

    func executeNextAction() {
      guard let nextAction = remainingActions.first else {
        notifyAllActionsCompleted()
        return
      }

      nextAction.actionBlock { _ in
        self.removeCompletedAction(nextAction)
        remainingActions = self.priorityActions.sorted()
        executeNextAction()
      }
    }
    executeNextAction()
  }

  // MARK: Private

  /// An array to store the prioritized network actions.
  private var priorityActions: [PriorityAction] = []

  /// The total number of completed network actions.
  private var totalNumberOfCompletedActions = 0

  /// The total number of network actions added.
  private var totalNumberOfActions = 0

  /// Callback to be executed when all network actions are completed.
  private var allActionsCompletion: (() -> Void)? = nil
}

// MARK: Helper methods

private extension NetworkPriorityDispatcher {
  /// Adds a network action to the composition.
  ///
  /// - Parameters:
  ///   - priority: The priority of the network action.
  ///   - actionBlock: A closure containing the network action.
  func addAction(priority: Priority, actionBlock: @escaping (@escaping (Any) -> Void) -> Void) {
    totalNumberOfActions += 1

    let action = PriorityAction(priority: priority, createdAt: Date(), actionBlock: actionBlock)
    priorityActions.append(action)
  }

  /// Removes a completed network action from the composition.
  ///
  /// - Parameter completedAction: The completed network action to be removed.
  func removeCompletedAction(_ completedAction: PriorityAction) {
    priorityActions.removeAll { $0 == completedAction }
    totalNumberOfCompletedActions += 1

    if totalNumberOfCompletedActions == totalNumberOfActions {
      notifyAllActionsCompleted()
    }
  }

  /// Notifies all completion callbacks that all network actions are completed.
  func notifyAllActionsCompleted() {
    totalNumberOfActions = 0
    totalNumberOfCompletedActions = 0

    allActionsCompletion?()
    allActionsCompletion = nil
  }
}
