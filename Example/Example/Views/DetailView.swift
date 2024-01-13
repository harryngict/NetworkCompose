//
//  DetailView.swift
//  Example
//
//  Created by Hoang Nguyezn on 20/11/23.
//

import NetworkCompose
import SwiftUI

struct DetailView: View {
    let type: DemoScenario
    @State private var artcles: [Post] = []
    @State private var errorMessage: String?
    @State private var isLoading: Bool = true

    var body: some View {
        VStack {
            if isLoading {
                ActivityIndicator()
                    .padding()
                Text("Loading...")
            } else {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(artcles, id: \.id) { article in
                        let value = article.title
                        Text(value)
                    }
                    .navigationBarTitle(type.rawValue)
                    .padding()
                }
            }
        }
        .onAppear {
            if case .multipleRequetWithPriority = type {
                MultiplePriorityRequest.shared.makeRequest(for: type) { result in
                    switch result {
                    case let .success(receivedUsers):
                        artcles = receivedUsers
                        isLoading = false
                    case let .failure(error):
                        errorMessage = "\(error.localizedDescription)"
                        isLoading = false
                    }
                }
            } else {
                SingleRequest.shared.makeRequest(for: type) { result in
                    switch result {
                    case let .success(receivedUsers):
                        artcles = receivedUsers
                        isLoading = false
                    case let .failure(error):
                        errorMessage = "\(error.localizedDescription)"
                        isLoading = false
                    }
                }
            }
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context _: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.startAnimating()
        return indicator
    }

    func updateUIView(_: UIActivityIndicatorView, context _: Context) {}
}
