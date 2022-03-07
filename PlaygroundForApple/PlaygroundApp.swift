//
//  playground_for_appleApp.swift
//  playground-for-apple
//
//  Created by Damodar Lohani on 26/09/2021.
//

import SwiftUI

@main
struct PlaygroundApp: App {
    var body: some Scene {
        WindowGroup {
            PlaygroundView(viewModel: PlaygroundViewModel())
        }
    }
}
