//
//  NetworkPriorityDispatcher.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 28/11/23.
//

import Foundation

public final class NetworkPriorityDispatcher<SessionType: NetworkSession>: NetworkBuilder<SessionType> {
    /// An array to store the prioritized network actions.
    private var priorityActions: [PriorityAction] = []

    /// The total number of completed network actions.
    private var totalNumberOfCompletedActions: Int = 0

    /// The total number of network actions added.
    private var totalNumberOfActions: Int = 0

    /// Callback to be executed when all network actions are completed.
    private var allActionsCompletion: (() -> Void)? = nil

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
    public func addRequest<RequestType: RequestInterface, ResultType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: RetryPolicy = .disabled,
        priority: Priority = .medium,
        completion: @escaping (Result<ResultType, NetworkError>) -> Void
    ) -> Self where RequestType.SuccessType == ResultType {
        addAction(priority: priority) { [weak self] actionCompletion in
            self?.build().request(request,
                                  andHeaders: headers,
                                  retryPolicy: retryPolicy)
            { requestResult in
                completion(requestResult.map { $0 as ResultType })
                actionCompletion(requestResult.map { $0 as ResultType })
            }
        }
        return self
    }

    /// Adds an upload task to the network composition with the specified priority.
    ///
    /// - Parameters:
    ///   - request: The request for the upload task.
    ///   - headers: The headers to be included in the request.
    ///   - fileURL: The URL of the file to be uploaded.
    ///   - retryPolicy: The retry policy for the upload task.
    ///   - priority: The priority of the upload task.
    ///   - completion: A closure to be called upon completion of the upload task.
    /// - Returns: The instance of `NetworkCompose` to allow method chaining.
    @discardableResult
    public func addUpload<RequestType: RequestInterface, ResultType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        fromFile fileURL: URL,
        retryPolicy: RetryPolicy = .disabled,
        priority: Priority = .medium,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) -> Self where RequestType.SuccessType == ResultType {
        addAction(priority: priority) { [weak self] actionCompletion in
            self?.build().upload(request,
                                 andHeaders: headers,
                                 fromFile: fileURL,
                                 retryPolicy: retryPolicy)
            { uploadResult in
                completion(uploadResult.map { $0 as ResultType })
                actionCompletion(uploadResult.map { $0 as ResultType })
            }
        }
        return self
    }

    /// Adds a download task to the network composition with the specified priority.
    ///
    /// - Parameters:
    ///   - request: The request for the download task.
    ///   - headers: The headers to be included in the request.
    ///   - retryPolicy: The retry policy for the download task.
    ///   - priority: The priority of the download task.
    ///   - completion: A closure to be called upon completion of the download task.
    /// - Returns: The instance of `NetworkCompose` to allow method chaining.
    @discardableResult
    public func addDownload<RequestType: RequestInterface, ResultType>(
        _ request: RequestType,
        andHeaders headers: [String: String] = [:],
        retryPolicy: RetryPolicy = .disabled,
        priority: Priority = .medium,
        completion: @escaping (Result<RequestType.SuccessType, NetworkError>) -> Void
    ) -> Self where RequestType.SuccessType == ResultType {
        addAction(priority: priority) { [weak self] actionCompletion in
            self?.build().download(request,
                                   andHeaders: headers,
                                   retryPolicy: retryPolicy)
            { downloadResult in
                completion(downloadResult.map { $0 as ResultType })
                actionCompletion(downloadResult.map { $0 as ResultType })
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
    public func cancelRequest<RequestType>(
        _ request: RequestType,
        priority: Priority = .medium
    ) -> Self where RequestType: RequestInterface {
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
