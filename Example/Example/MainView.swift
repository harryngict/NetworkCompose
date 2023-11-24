//
//  MainView.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import SwiftUI

enum ExampleType: String {
    case requestAsync = "Request async await for iOS-15 above"
    case requestCompletion = "Request completion closure"
    case requestQueue = "Request and auto re-authentication"
    case requestWithSSL = "Request with SSL Pinning"
    case requestReportMetric = "Request with report metric"
    case requestRetry = "Request with retry"
    case requestMock = "Request mocking support for unit tests"
}

struct MainView: View {
    @State private var selectedType: ExampleType?

    let types: [ExampleType] = [.requestAsync, .requestCompletion,
                                .requestQueue, .requestWithSSL,
                                .requestReportMetric, .requestRetry,
                                .requestMock]

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
            .navigationBarTitle("NetworkSwift", displayMode: .inline)
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
