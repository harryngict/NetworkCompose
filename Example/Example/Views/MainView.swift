//
//  MainView.swift
//  Example
//
//  Created by Hoang Nguyezn on 18/11/23.
//

import SwiftUI

struct MainView: View {
    @State private var selectedType: DemoScenario?

    let types: [DemoScenario] = [.defaultRequest,
                                 .enabledSSLPinning, .networkMetricReport,
                                 .smartRetry,
                                 .multipleRequetWithPriority]

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
            .navigationBarTitle("NetworkCompose demo", displayMode: .inline)
        }
    }
}

struct CustomCell: View {
    let type: DemoScenario
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
