//
//  MomentumApp.swift
//  Momentum
//
//  Created by Mutaz on 3/5/2026.
//

import SwiftUI

@main
struct MomentumApp: App {
    // store holds all our habits and is shared across the whole app
    @StateObject var store = HabitStore()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(store)
                .onAppear {
                    // ask the user for notification permission when app opens
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}


