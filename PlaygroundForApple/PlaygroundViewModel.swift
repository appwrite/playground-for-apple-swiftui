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
        .setEndpoint("YOUR_ENDPOINT")
        .setProject("YOUR_PROJECT_ID")
        .setSelfSigned()
    
    let account: Account
    let storage: Storage
    let database: Databases
    let functions: Functions
    let realtime: Realtime
    
    var databaseId = "YOUR_DATABASE_ID"
    var collectionId = "YOUR_COLLECTION_ID"
    var bucketId = "YOUR_BUCKET_ID"
    var functionId = "YOUR_FUNCTION_ID"
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
        database = Databases(client)
        realtime = Realtime(client)
        
        Task { try! await getAccount() }
    }
    
    func createAccount() async throws {
        userEmail = "\(Int.random(in: 1..<Int.max))@example.com"
        
        do {
            let user = try await account.create(
                userId: ID.unique(),
                email: userEmail,
                password: "password"
            )
            userId = user.id
            dialogText = String(describing: user.toMap())
            
            try await getAccount()
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    private func getAccount() async throws {
        do {
            let user = try await account.get()
            dialogText = String(describing: user.toMap())
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func createSession() async throws {
        do {
            let session = try await account.createEmailSession(
                email: userEmail,
                password: "password"
            )
            dialogText = String(describing: session.toMap())
            
            try await getAccount()
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func createAnonymousSession() async throws {
        do {
            let session = try await account.createAnonymousSession()
            dialogText = String(describing: session.toMap())
            
            try await getAccount()
        } catch {
            dialogText = error.localizedDescription
        }
            isShowingDialog = true
    }
    
    func listSessions() async throws {
        do {
            let sessions = try await account.listSessions()
            dialogText = String(describing: sessions.toMap())
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func deleteSessions() async throws {
        do {
            _ = try await account.deleteSessions()
            dialogText = "Sessions Deleted."
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func deleteSession() async throws {
        do {
            _ = try await account.deleteSession(sessionId: "current")
            dialogText = "Session Deleted."
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func subscribe() {
        _ = realtime.subscribe(channel: "databases.\(databaseId).collections.\(collectionId).documents") { event in
            DispatchQueue.main.async {
                self.message = String(describing: event.payload!)
            }
        }
    }
    
    func createDoc() async throws {
        do {
            let doc = try await database.createDocument(
                databaseId: databaseId,
                collectionId: collectionId,
                documentId: ID.unique(),
                data: ["username": "Apple SwiftUI"],
                permissions: [
                    Permission.read(Role.users()),
                    Permission.update(Role.users()),
                    Permission.delete(Role.users())
                ]
            )
            documentId = doc.id
            dialogText = String(describing: doc.toMap())
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func listDocs() async throws {
        do {
            let docs = try await database.listDocuments(
                databaseId: databaseId,
                collectionId: collectionId,
                queries: [
                    Query.equal("username", value: "Apple SwiftUI")
                ]
            )
            dialogText = String(describing: docs.toMap())
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func deleteDoc() async throws {
        do {
            _ = try await database.deleteDocument(
                databaseId: databaseId,
                collectionId: collectionId,
                documentId: documentId
            )
            dialogText = "Document Deleted."
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func preview() async throws {
        do {
            let response = try await storage.getFilePreview(
                bucketId: bucketId,
                fileId: fileId,
                width: 300
            )
            downloadedImage = Image(uiImage: UIImage(data: Data(buffer: response))!)
        } catch {
            dialogText = error.localizedDescription
            isShowingDialog = true
        }
    }
    
    func uploadFile(image: UIImage) async throws {

        let file = InputFile.fromData(
            image.jpegData(compressionQuality: 1)!,
            filename: "file.png",
            mimeType: "image/png"
        )

        do {
            let file = try await storage.createFile(
                bucketId: bucketId,
                fileId: ID.unique(),
                file: file,
                permissions: [
                    Permission.read(Role.users()),
                    Permission.update(Role.users()),
                    Permission.delete(Role.users()),
                ]
            )
            fileId = file.id
            dialogText = String(describing: file.toMap())
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func listFiles() async throws {
        do {
            let files = try await storage.listFiles(bucketId: bucketId)
            dialogText = String(describing: files.toMap())
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func deleteFile() async throws {
        do {
            _ = try await storage.deleteFile(bucketId: bucketId, fileId: fileId)
            dialogText = "File Deleted."
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func createExecution() async throws {
        do {
            let execution = try await functions.createExecution(functionId: functionId)
            executionId = execution.id
            dialogText = String(describing: execution.toMap())
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func listExecutions() async throws {
        do {
            let executions = try await functions.listExecutions(functionId: functionId)
            dialogText = String(describing: executions.toMap())
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func getExecution() async throws {
        do {
            let execution = try await functions.getExecution(
                functionId: functionId, 
                executionId: executionId
            )
            dialogText = String(describing: execution.toMap())
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
    
    func generateJWT() async throws {
        do {
            let jwt = try await account.createJWT()
            dialogText = String(describing: jwt.toMap())
        } catch {
            dialogText = error.localizedDescription
        }
    }
    
    func socialLogin(provider: String) async throws {
        do {
            _ = try await account.createOAuth2Session(provider: provider)
            dialogText = "OAuth Success!"
        } catch {
            dialogText = error.localizedDescription
        }
        isShowingDialog = true
    }
}
