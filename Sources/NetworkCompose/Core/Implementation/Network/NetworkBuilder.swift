//
//  NetworkBuilder.swift
//  NetworkCompose
//
//  Created by Hoang Nguyen on 24/11/23.
//

import Foundation

public class NetworkBuilder<SessionType: NetworkSession>: NetworkBuilderBase<SessionType> {
    public required init(baseURL: URL,
                         session: SessionType = URLSession.shared)
    {
        super.init(baseURL: baseURL,
                   session: session)
    }

    public func build() -> NetworkInterface {
        guard let strategy = strategy, case let .mocker(provider) = strategy else {
            return Network(
                baseURL: baseURL,
                session: session,
                networkReachability: networkReachability,
                executeQueue: executeQueue,
                observeQueue: observeQueue
            )
        }
        return NetworkDecorator(
            baseURL: baseURL,
            session: session,
            executeQueue: executeQueue,
            observeQueue: observeQueue,
            expectations: provider.networkExpectations
        )
    }
}
