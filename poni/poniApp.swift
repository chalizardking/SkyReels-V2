//
//  poniApp.swift
//  poni
//
//  Created by Cha Lizardking on 7/7/25.
//

import SwiftUI
import SwiftData

@main
struct poniApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(
                for: Horse.self, Jockey.self, Trainer.self, Race.self, RaceEntry.self
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
