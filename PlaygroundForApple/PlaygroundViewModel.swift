//
//  PlaygroundViewModel.swift
//  PlaygroundForApple
//
//  Created by Damodar Lohani on 26/09/2021.
//

import SwiftUI
import Appwrite
import NIO

class PlaygroundViewModel: ObservableObject {
    
    let client = Client()
        .setEndpoint("http://192.168.4.23/v1")
        .setProject("playground-for-swift-ui")
        .setSelfSigned()
    
    let account: Account
    let storage: Storage
    let database: Database
    let functions: Functions
    let realtime: Realtime
    
    var collectionId = "test"
    var bucketId = "test"
    var functionId = "test"
    var executionId = ""
    var userId = ""
    var userEmail = ""
    var documentId = ""
    var fileId = ""
    
    @Published var error: String = ""
    @Published var userName: String = "No Session"
    @Published var message: String = ""
    @Published var downloadedImage: Image? = nil
    @Published var isShowingDialog = false
    @Published var dialogText: String = ""
    
    init() {
        account = Account(client)
        storage = Storage(client)
        functions = Functions(client)
        database = Database(client)
        realtime = Realtime(client)
        
        getAccount()
    }
    
    func createAccount() {
        userEmail = "\(Int.random(in: 1..<Int.max))@example.com"
        
        account.create(
            userId: "unique()",
            email: userEmail,
            password: "password"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let user):
                    self.userId = user.id
                    self.dialogText = String(describing: user.toMap())
                    self.getAccount()
                }
                self.isShowingDialog = true
            }
        }
    }
    
    private func getAccount() {
        account.get { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let user):
                    self.dialogText = String(describing: user.toMap())
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func createSession() {
        account.createSession(
            email: userEmail,
            password: "password"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let session):
                    self.dialogText = String(describing: session.toMap())
                    self.getAccount()
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func createAnonymousSession() {
        account.createAnonymousSession() { result in
            switch result {
            case .failure(let err):
                DispatchQueue.main.async {
                    self.dialogText = err.message
                    self.isShowingDialog = true
                }
            case .success:
                self.getAccount()
            }
        }
    }
    
    func listSessions() {
        account.getSessions { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let sessions):
                    self.dialogText = String(describing: sessions.toMap())
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func deleteSessions() {
        account.deleteSessions { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success:
                    self.dialogText = "Sessions Deleted."
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func deleteSession() {
        account.deleteSession(sessionId: "current") { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success:
                    self.dialogText = "Session Deleted."
                }
                self.isShowingDialog = true
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
        database.createDocument(
            collectionId: collectionId,
            documentId: "unique()",
            data: ["username": "user 1"],
            read: ["role:all"]
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let doc):
                    self.documentId = doc.id
                    self.dialogText = String(describing: doc.toMap())
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func listDocs() {
        database.listDocuments(collectionId: collectionId) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let docs):
                    self.dialogText = String(describing: docs.toMap())
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func deleteDoc() {
        database.deleteDocument(
            collectionId: collectionId,
            documentId: documentId
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success:
                    self.dialogText = "Document Deleted."
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func preview() {
        storage.getFilePreview(
            bucketId: self.bucketId,
            fileId: fileId,
            width: 300
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self.dialogText = error.message
                    self.isShowingDialog = true
                case .success(let response):
                    self.downloadedImage = Image(uiImage: UIImage(data: Data(buffer: response))!)
                }
            }
        }
    }
    
    func uploadFile(image: UIImage) {
        let imageBuffer = ByteBufferAllocator()
            .buffer(data: image.jpegData(compressionQuality: 1)!)
        
        storage.createFile(
            bucketId: bucketId,
            fileId: "unique()",
            file: File(name: "file.png", buffer: imageBuffer),
            onProgress: nil
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let file):
                    self.fileId = file.id
                    self.dialogText = String(describing: file.toMap())
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func listFiles() {
        storage.listFiles(bucketId: bucketId) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let files):
                    self.dialogText = String(describing: files.toMap())
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func deleteFile() {
        storage.deleteFile(
            bucketId: bucketId,
            fileId: fileId
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success:
                    self.dialogText = "File Deleted."
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func createExecution() {
        functions.createExecution(functionId: functionId) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let execution):
                    self.executionId = execution.id
                    self.dialogText = String(describing: execution.toMap())
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func listExecutions() {
        functions.listExecutions(functionId: functionId) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let executions):
                    self.dialogText = String(describing: executions.toMap())
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func getExecution() {
        functions.getExecution(
            functionId: functionId,
            executionId: executionId
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let execution):
                    self.dialogText = String(describing: execution.toMap())
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func generateJWT() {
        account.createJWT() { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success(let jwt):
                    self.dialogText = String(describing: jwt.toMap())
                }
                self.isShowingDialog = true
            }
        }
    }
    
    func socialLogin(provider: String) {
        account.createOAuth2Session(provider: provider) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let err):
                    self.dialogText = err.message
                case .success:
                    self.getAccount()
                    self.dialogText = "OAuth Success!"
                }
                self.isShowingDialog = true
            }
        }
    }
}
