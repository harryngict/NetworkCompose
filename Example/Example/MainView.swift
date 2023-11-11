//
//  MainView.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import SwiftUI

enum ExampleType: String {
    case requestCompletion = "Request with completion"
    case requestAsync = "Request with async iOS 15"
    case requestQueue = "Request queue with auto re-auth"
    case uploadFile = "Request upload file"
    case downloadFile = "Request download file"
    case requestMock = "Request mock for testing"
}

struct MainView: View {
    @State private var selectedType: ExampleType?

    let types: [ExampleType] = [.requestCompletion, .requestAsync, .requestQueue, .uploadFile, .downloadFile, .requestMock]

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
            .navigationBarTitle("NetworkKit - NK", displayMode: .inline)
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
