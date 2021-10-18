//
//  ContentView.swift
//  playground-for-apple
//
//  Created by Damodar Lohani on 26/09/2021.
//

import SwiftUI
import Appwrite

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var isShowPhotoLibrary = false
    @State private var imageToUpload = UIImage()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Group {
                        Button("Anonymous Login") {
                            viewModel.loginAnonymous()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(Color.gray)
                        
                        Button("Login with Email") {
                            viewModel.login()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(Color.gray)
                    }
                    
                    Group {
                        Button("Subscribe") {
                            viewModel.subscribe()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(Color.blue)
                        
                        Button("Create Doc") {
                            viewModel.createDoc()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(Color.blue)
                        
                        Button("Upload File") {
                            self.isShowPhotoLibrary = true
                        }
                        .padding()
                        .frame(width: 250)
                        .background(Color.blue)
                        
                        Button("Generate JWT") {
                            viewModel.generateJWT()
                        }
                        .padding()
                        .frame(width: 250)
                        .background(Color.blue)
                    }
                    
                    
                    Group {
                        Button("Login With Facebook") {
                            viewModel.socialLogin(provider: "facebook")
                        }
                        .padding()
                        .frame(width: 250)
                        .background(Color.blue)
                        
                        Button("Login with GitHub") {
                            viewModel.socialLogin(provider: "github")
                        }
                        .padding()
                        .frame(width: 250)
                        .background(Color.blue)
                        
                        Button("Login with Google") {
                            viewModel.socialLogin(provider: "apple")
                        }
                        .padding()
                        .frame(width: 250)
                        .background(Color.red)
                    }
                    
                    viewModel.downloadedImage?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                    
                    if(!viewModel.error.isEmpty) {
                        Text(String(viewModel.error))
                            .foregroundColor(.red)
                    }
                    
                    
                    Text(viewModel.userName)
                        .foregroundColor(.pink)
                        .font(.title)
                    
                    if(!viewModel.message.isEmpty) {                    
                        Text(viewModel.message)
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Button("Logout") {
                        viewModel.logOut()
                    }
                    .padding()
                    .frame(width: 250)
                    .background(Color.red)
                    
                }
                .sheet(isPresented: $isShowPhotoLibrary) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: self.$imageToUpload)
                }
                .onChange(of: imageToUpload) { img in
                    viewModel.uploadFile(image: img)
                }
                .foregroundColor(.white)
            .navigationTitle("Appwrite + iOS = ♥️")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ViewModel())
    }
}
