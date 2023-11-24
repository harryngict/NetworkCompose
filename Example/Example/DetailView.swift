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
            ClientNetworkDemo
                .shared
                .makeRequest(for: type) { receivedResult in
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
