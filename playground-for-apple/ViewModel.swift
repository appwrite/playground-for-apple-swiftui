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
    
    @Published var error: String?
    @Published var userName: String?
    @Published var response: String = ""
    
    init() {
        client = Client()
            .setEndpoint("https://demo.appwrite.io/v1")
            .setProject("608fa1dd20ef0")
        
        account = Account(client: client)
        storage = Storage(client: client)
        database = Database(client: client)
        realtime = Realtime(client: client)
    }
    
    private func getAccount() {
        account.get() { result in
            switch result {
            case .failure(let err):
                self.error = err.message
            case .success(var res):
                DispatchQueue.main.async {
                    self.response = res.body!.readString(length: res.body!.readableBytes) ?? ""
                    self.error = "Login successful"
                }
            }
            
        }
    }
    
    func loginAnonymous() {
        account.createAnonymousSession() { result in
            switch result {
            case .failure(let err):
                self.error = err.message
            case .success:
                self.getAccount()
            }
        }
    }
    
    func login() {
        account.createSession(email: "user@appwrite.io", password: "password") {result in
            switch result {
            case .failure(let err):
                self.error = err.message
            case .success:
                self.getAccount()
            }
        }
    }
    
    func subscribe() {
        _ = realtime.subscribe(channels: ["collections.\(collectionId).documents"]) { event in
            self.response = String(describing: event.payload!)
        }
    }
    
    func createDoc() {
        database.createDocument(collectionId: collectionId, data: ["username": "user 1"], read: ["*"], write: ["*"]) { result in
            switch result {
            case .failure(let err):
                self.error = err.message
            case .success(var res):
                self.response = res.body!.readString(length: res.body!.readableBytes) ?? ""
            }
        }
    }
    
    func uploadFile(image: UIImage) {
        let imageBuffer = ByteBufferAllocator()
            .buffer(data: image.jpegData(compressionQuality: 1)!)
        
        let file = File(name: "file.png", buffer: imageBuffer)
        
        storage.createFile(file: file) { result in
            switch result {
            case .failure(let err):
                self.error = err.message
            case .success(var res):
                self.response = res.body!.readString(length: res.body!.readableBytes) ?? ""
            }
        }
    }
    
    func generateJWT() {
        account.createJWT() { result in
            switch result {
            case .failure(let err):
                self.error = err.message
            case .success(var res):
                self.response = res.body!.readString(length: res.body!.readableBytes) ?? ""
            }
        }
    }
    
    func socialLogin(provider: String) {
        account.createOAuth2Session(provider: provider) { result in
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
    
    func logOut() {
        account.deleteSession(sessionId: "current") { result in
            switch result {
            case .failure(let err):
                self.error = err.message
            case .success:
                self.userName = "No session"
                self.response = ""
            }
        }
    }
}
