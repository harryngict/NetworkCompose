//
//  DetailView.swift
//  Example
//
//  Created by Hoang Nguyen on 20/11/23.
//

import SwiftUI

struct DetailView: View {
    let type: ExampleType
    @State private var result: String = ""
    @State private var isLoading: Bool = true

    private enum Constant {
        static let baseURL: String = "https://655abc126981238d054dacd0.mockapi.io/api/v1"
    }

    var body: some View {
        VStack {
            if isLoading {
                ActivityIndicator()
                    .padding()
                Text("Loading...")
            } else {
                Text(result)
                    .navigationBarTitle(type.rawValue)
                    .padding()
            }
        }
        .onAppear {
            guard let baseURL = URL(string: Constant.baseURL) else {
                return
            }

            ClientNetworkFactory(baseURL: baseURL).makeRequest(for: type) { receivedResult in
                result = receivedResult
                isLoading = false
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

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(type: .requestCompletion)
    }
}
