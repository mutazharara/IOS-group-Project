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

            //home tab - shows todays habits
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            Color.clear
                .tabItem {
                    Label("Add", systemImage: "plus")
                }
                .tag(1)

            // timer tab
            NavigationStack {
                TimerView()
            }
            .tabItem {
                Label("Timer", systemImage: "timer")
            }
            .tag(2)
 
            // stats tab
            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            .tag(3)
        }
        .accentColor(.black)
        
        .onChange(of: selectedTab) {
            if selectedTab == 1 {
                // open the add habit sheet and go back to home tab
                showAddHabit = true
                selectedTab = 0
            }
        }
        .sheet(isPresented: $showAddHabit) {
            AddHabitView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HabitStore())
}
