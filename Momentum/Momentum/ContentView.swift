//
//  ContentView.swift
//  Momentum
//
//  Created by Mutaz on 3/5/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: HabitStore
    @State private var showAddHabit = false
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)


            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            .tag(2)
        }
        .accentColor(.orange)
        
    }
}

#Preview {
    ContentView()
        .environmentObject(HabitStore())
}
