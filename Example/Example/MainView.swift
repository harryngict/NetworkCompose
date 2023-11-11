//
//  MainView.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import SwiftUI

enum ExampleType: String {
    case requestCompletion = "Request completion closure"
    case requestAsync = "Request async await for iOS-15 above"
    case requestQueue = "Request and auto re-authentication"
    case downloadFile = "Download File"
    case uploadFile = "Upload File"
    case requestWithSSL = "Request with SSL Pinning"
    case requestQueueWithSSL = "Request and auto re-authentication with SSL Pinning"
    case requestMock = "Mocking support for unit tests"
}

struct MainView: View {
    @State private var selectedType: ExampleType?

    let types: [ExampleType] = [.requestAsync, .requestCompletion,
                                .requestQueue, .downloadFile,
                                .uploadFile, .requestWithSSL,
                                .requestQueueWithSSL, .requestMock]

    var body: some View {
        NavigationView {
            List {
                ForEach(types, id: \.self) { type in
                    NavigationLink(destination: DetailView(type: type), tag: type, selection: $selectedType) {
                        CustomCell(type: type) {
                            selectedType = type
                        }
                    }
                }
            }
            .navigationBarTitle("NetworkSwift - NK", displayMode: .inline)
        }
    }
}

struct CustomCell: View {
    let type: ExampleType
    var onTap: () -> Void

    var body: some View {
        HStack {
            Text(type.rawValue)
                .font(.headline)
                .padding(8)
        }
        .onTapGesture {
            onTap()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
