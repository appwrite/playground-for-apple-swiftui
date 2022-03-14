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
                            viewModel.createAccount()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.yellow)
                        
                        Button("Create Session") {
                            viewModel.createSession()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.pink)
                        
                        Button("Create Anonymous Session") {
                            viewModel.createAnonymousSession()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.green)
                        
                        Button("List Sessions") {
                            viewModel.listSessions()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.gray)
                        
                        Button("Delete Current Session") {
                            viewModel.deleteSession()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.orange)
                        
                        Button("Delete All Sessions") {
                            viewModel.deleteSessions()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.cyan)
                        
                        Button("Generate JWT") {
                            viewModel.generateJWT()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.blue)
                    }
                    
                    Group {
                        Button("Login With Facebook") {
                            viewModel.socialLogin(provider: "facebook")
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.gray)
                        
                        Button("Login with GitHub") {
                            viewModel.socialLogin(provider: "github")
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.blue)
                        
                        Button("Login with Google") {
                            viewModel.socialLogin(provider: "apple")
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.red)
                    }
                    
                    Group {
                        Button("Create Doc") {
                            viewModel.createDoc()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.blue)
                        
                        Button("List Docs") {
                            viewModel.listDocs()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.green)
                        
                        Button("Delete Doc") {
                            viewModel.deleteDoc()
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
                            viewModel.listFiles()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.mint)
                        
                        Button("Delete File") {
                            viewModel.deleteFile()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.indigo)
                        
                    }
                    
                    Group {
                        Button("Create Execution") {
                            viewModel.createExecution()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.blue)
                        
                        Button("List Executions") {
                            viewModel.listExecutions()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(.green)
                        
                        Button("Get Execution") {
                            viewModel.getExecution()
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
                        viewModel.deleteSession()
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
                    viewModel.uploadFile(image: img)
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
