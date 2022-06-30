//
//  ContentView.swift
//  playground-for-apple
//
//  Created by Damodar Lohani on 26/09/2021.
//

import SwiftUI
import Appwrite

struct PlaygroundView: View {
    @ObservedObject var viewModel: PlaygroundViewModel
    
    @State private var isShowPhotoLibrary = false
    @State private var imageToUpload = UIImage()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Group {
                        Button("Create Account") {
                            Task {
                                try await viewModel.createAccount()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.yellow)
                        
                        Button("Create Session") {
                            Task {
                                try await viewModel.createSession()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.pink)
                        
                        Button("Create Anonymous Session") {
                            Task {
                                try await viewModel.createAnonymousSession()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.green)
                        
                        Button("List Sessions") {
                            Task {
                                try await viewModel.listSessions()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.gray)
                        
                        Button("Delete Current Session") {
                            Task {
                                try await viewModel.deleteSession()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.orange)
                        
                        Button("Delete All Sessions") {
                            Task {
                                try await viewModel.deleteSessions()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.cyan)
                        
                        Button("Generate JWT") {
                            Task {
                                try await viewModel.generateJWT()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.blue)
                    }
                    
                    Group {
                        Button("Login With Facebook") {
                            Task {
                                try await viewModel.socialLogin(provider: "facebook")
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.gray)
                        
                        Button("Login with GitHub") {
                            Task {
                                try await viewModel.socialLogin(provider: "github")
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.blue)
                        
                        Button("Login with Google") {
                            Task {
                                try await viewModel.socialLogin(provider: "apple")
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.red)
                    }
                    
                    Group {
                        Button("Create Doc") {
                            Task {
                                try await viewModel.createDoc()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.blue)
                        
                        Button("List Docs") {
                            Task {
                                try await viewModel.listDocs()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.green)
                        
                        Button("Delete Doc") {
                            Task {
                                try await viewModel.deleteDoc()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.pink)
                    }
                    
                    Group {
                        Button("Upload File") {
                            self.isShowPhotoLibrary = true
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.orange)
                        
                        Button("List Files") {
                            Task {
                                try await viewModel.listFiles()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.mint)
                        
                        Button("Delete File") {
                            Task {
                                try await viewModel.deleteFile()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.indigo)
                        
                    }
                    
                    Group {
                        Button("Create Execution") {
                            Task {
                                try await viewModel.createExecution()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.blue)
                        
                        Button("List Executions") {
                            Task {
                                try await viewModel.listExecutions()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.green)
                        
                        Button("Get Execution") {
                            Task {
                                try await viewModel.getExecution()
                            }
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.pink)
                    }
                    
                    Group {
                        Button("Subscribe") {
                           viewModel.subscribe()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.teal)
                    }
                    
                    viewModel.downloadedImage?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                    
                    Text(viewModel.userName)
                        .foregroundColor(.pink)
                        .font(.title)
                    
                    Button("Logout") {
                        Task {
                            try await viewModel.deleteSession()
                        }
                    }
                    .padding()
                    .frame(width: 250)
                    .background(Color.red)
                    
                }
                .foregroundColor(.white)
                .alert(isPresented: $viewModel.isShowingDialog) {
                    Alert(
                        title: Text("Alert"),
                        message: Text(viewModel.dialogText),
                        dismissButton: .cancel {
                            viewModel.isShowingDialog = false
                        }
                    )
                }
                .sheet(isPresented: $isShowPhotoLibrary) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: self.$imageToUpload)
                    
                }
                .onChange(of: imageToUpload) { img in
                    Task {
                        try await viewModel.uploadFile(image: img)
                    }
                }
            }.navigationTitle("Appwrite + iOS = ♥️")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundView(viewModel: PlaygroundViewModel())
    }
}
