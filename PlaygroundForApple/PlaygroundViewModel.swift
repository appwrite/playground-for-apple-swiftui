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
        
        Task {
            try await getAccount()
        }
    }
    
    func createAccount() async throws {
        userEmail = "\(Int.random(in: 1..<Int.max))@example.com"
        
        do {
            let user = try await account.create(
                userId: "unique()",
                email: userEmail,
                password: "password"
            )
            self.userId = user.id
            self.dialogText = String(describing: user.toMap())
            
            try await self.getAccount()
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    private func getAccount() async throws {
        do {
            let user = try await account.get()
            self.dialogText = String(describing: user.toMap())
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func createSession() async throws {
        do {
            let session = try await account.createSession(
                email: userEmail,
                password: "password"
            )
            self.dialogText = String(describing: session.toMap())
            
            try await self.getAccount()
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func createAnonymousSession() async throws {
        do {
            _ = try await account.createAnonymousSession()
            
            try await self.getAccount()
        } catch let error as AppwriteError {
            self.dialogText = error.message
            self.isShowingDialog = true
        }
    }
    
    func listSessions() async throws {
        do {
            let sessions = try await account.getSessions()
            self.dialogText = String(describing: sessions.toMap())
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func deleteSessions() async throws {
        do {
            _ = try await account.deleteSessions()
            self.dialogText = "Sessions deleted."
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func deleteSession() async throws {
        do {
            try await account.deleteSession(sessionId: "current")
            self.dialogText = "Session deleted."
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func subscribe() {
        _ = realtime.subscribe(channels: ["collections.\(collectionId).documents"]) { event in
            DispatchQueue.main.async {
                self.message = String(describing: event.payload!)
            }
        }
    }
    
    func createDoc() async throws {
        do {
            let doc = try await database.createDocument(
                collectionId: collectionId,
                documentId: "unique()",
                data: ["username": "user 1"],
                read: ["role:all"]
            )
            self.documentId = doc.id
            self.dialogText = String(describing: doc.toMap())
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func listDocs() async throws {
        do {
            let docs = try await database.listDocuments(collectionId: collectionId)
            self.dialogText = String(describing: docs.toMap())
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func deleteDoc() async throws {
        do {
            try await database.deleteDocument(
                collectionId: collectionId,
                documentId: documentId
            )
            self.dialogText = "Document deleted."
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func preview() async throws {
        do {
            let response = try await storage.getFilePreview(
                bucketId: self.bucketId,
                fileId: fileId,
                width: 300
            )
            self.downloadedImage = Image(uiImage: UIImage(data: Data(buffer: response))!)
        } catch let error as AppwriteError {
            self.dialogText = error.message
            self.isShowingDialog = true
        }
    }
    
    func uploadFile(image: UIImage) async throws {
        let imageBuffer = ByteBufferAllocator()
            .buffer(data: image.jpegData(compressionQuality: 1)!)
        
        do {
            let file = try await storage.createFile(
                bucketId: bucketId,
                fileId: "unique()",
                file: File(name: "file.png", buffer: imageBuffer),
                onProgress: nil
            )
            self.fileId = file.id
            self.dialogText = String(describing: file.toMap())
        } catch let error as AppwriteError {
            self.dialogText = error.message
            
        }
        self.isShowingDialog = true
    }
    
    func listFiles() async throws {
        do {
            let files = try await storage.listFiles(bucketId: bucketId)
            self.dialogText = String(describing: files.toMap())
        } catch let error as AppwriteError {
            self.dialogText = error.message
            
        }
        self.isShowingDialog = true
    }
    
    func deleteFile() async throws {
        do {
            try await storage.deleteFile(bucketId: bucketId, fileId: fileId)
            self.dialogText = "File deleted."
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func createExecution() async throws {
        do {
            let execution = try await functions.createExecution(functionId: functionId)
            self.dialogText = String(describing: execution.toMap())
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func listExecutions() async throws {
        do {
            let executions = try await functions.listExecutions(functionId: functionId)
            self.dialogText = String(describing: executions.toMap())
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func getExecution() async throws {
        do {
            let execution = try await functions.getExecution(
                functionId: functionId,
                executionId: executionId
            )
            self.dialogText = String(describing: execution.toMap())
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func generateJWT() async throws {
        do {
            let jwt = try await account.createJWT()
            self.dialogText = String(describing: jwt.toMap())
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
    
    func socialLogin(provider: String) async throws {
        do {
            try await account.createOAuth2Session(provider: provider)
            self.dialogText = "OAuth Success."
        } catch let error as AppwriteError {
            self.dialogText = error.message
        }
        self.isShowingDialog = true
    }
}
