//
//  ContentView.swift
//  Example
//
//  Created by Hoang Nguyen on 18/11/23.
//

import SwiftUI

struct ContentView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""

    let types: [RequestType] = [.requestCompletion, .requestAsync, .requestQueue, .uploadFile, .downloadFile, .requestMock]

    var body: some View {
        NavigationView {
            List {
                ForEach(types, id: \.self) { type in
                    CustomCell(type: type) {
                        guard let baseURL = URL(string: OnlineRemoteConfig.shared.apiConfig?.baseURL ?? "") else {
                            return
                        }
                        ClientNetworkFactory(baseURL: baseURL).makeRequest(for: type) { message in
                            alertMessage = message
                            showAlert = true
                        }
                    }
                }
            }
            .navigationBarTitle("NetworkKit - NK", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("NetworkKit result:"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Ok"))
                )
            }
        }
    }
}

struct CustomCell: View {
    let type: RequestType
    var onTap: () -> Void

    var body: some View {
        HStack {
            Text(type.rawValue)
                .font(.headline)
                .padding(8)

            Spacer()

            Image(systemName: "chevron.right")
                .padding(8)
                .foregroundColor(.gray)
        }
        .onTapGesture {
            onTap()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum RequestType: String {
    case requestCompletion = "Request with completion"
    case requestAsync = "Request with async iOS 15"
    case requestQueue = "Request queue with auto re-auth"
    case uploadFile = "Request upload file"
    case downloadFile = "Request download file"
    case requestMock = "Request mock for testing"
}
