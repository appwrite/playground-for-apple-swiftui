//
//  ViewModel.swift
//  playground-for-apple
//
//  Created by Damodar Lohani on 26/09/2021.
//

import SwiftUI
import Appwrite
import NIO

class ViewModel: ObservableObject {
    var client: Client
    var account: Account
    var storage: Storage
    var database: Database
    var realtime: Realtime
    
    var collectionId = "608faab562521"
    
    @Published var error: String = ""
    @Published var userName: String = "No Session"
    @Published var message: String = ""
    @Published var downloadedImage: Image? = nil
    
    var fileId: String = ""
    
    init() {
        client = Client()
            .setEndpoint("https://demo.appwrite.io/v1")
            .setProject("608fa1dd20ef0")
        
        account = Account(client)
        storage = Storage(client)
        database = Database(client)
        realtime = Realtime(client)
        getAccount()
    }
    
    private func getAccount() {
        account.get() { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.error = err.message
                case .success(let res):
                    DispatchQueue.main.async {
                        self.error = ""
                        if(res.name.isEmpty) {
                            self.userName = "Anonymous User"
                        } else {
                            self.userName = res.name
                        }
                    }
                }
                
            }
        }
    }
    
    func loginAnonymous() {
        account.createAnonymousSession() { result in
            switch result {
            case .failure(let err):
                DispatchQueue.main.async {
                    self.error = err.message
                }
            case .success:
                self.getAccount()
            }
        }
    }
    
    func login() {
        account.createSession(email: "user@appwrite.io", password: "password") {result in
            switch result {
            case .failure(let err):
                DispatchQueue.main.async {
                    self.error = err.message
                }
            case .success:
                self.getAccount()
            }
        }
    }
    
    func subscribe() {
        _ = realtime.subscribe(channels: ["collections.\(collectionId).documents"]) { event in
            DispatchQueue.main.async {
                self.message = String(describing: event.payload!)
            }
        }
    }
    
    func createDoc() {
        database.createDocument(collectionId: collectionId, data: ["username": "user 1"], read: ["*"], write: ["*"]) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.error = err.message
                case .success(let doc):
                    DispatchQueue.main.async {
                        self.message = doc.id
                    }
                }
            }
        }
    }
    
    func preview() {
        storage.getFilePreview(fileId: fileId, width: 300) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error): self.message = error.message
                case .success(let response):
                    self.downloadedImage = Image(uiImage: UIImage(data: Data(buffer: response))!)
                }
            }
        }
    }
    
    func uploadFile(image: UIImage) {
        let imageBuffer = ByteBufferAllocator()
            .buffer(data: image.jpegData(compressionQuality: 1)!)
        
        let file = File(name: "file.png", buffer: imageBuffer)
        
        storage.createFile(file: file) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.error = err.message
                case .success(let file):
                    DispatchQueue.main.async {
                        self.message = file.id
                        self.fileId = file.id
                    }
                }
            }
        }
    }
    
    func generateJWT() {
        account.createJWT() { result in
            DispatchQueue.main.async {
                
                switch result {
                case .failure(let err):
                    self.error = err.message
                case .success(let res):
                    self.message = res.jwt
                }
            }
        }
    }
    
    func socialLogin(provider: String) {
        account.createOAuth2Session(provider: provider) { result in
            DispatchQueue.main.async {
                
                switch result {
                case .failure(let err):
                    self.error = err.message
                case .success(let res):
                    if res {
                        self.getAccount()
                    }
                }
            }
        }
    }
    
    func logOut() {
        account.deleteSession(sessionId: "current") { result in
            switch result {
            case .failure(let err):
                self.error = err.message
            case .success:
                self.userName = "No session"
                self.message = ""
            }
        }
    }
}
