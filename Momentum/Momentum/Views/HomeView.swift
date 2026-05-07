//
//  HomeView.swift
//  Momentum
//
//  Created by Mutaz on 3/5/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: HabitStore
    @State private var showAddHabit = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // top header showing how many habits are done today
            HStack {
                Text("My Habits")
                    .font(.headline)
                Spacer()
                Text("\(store.doneCount)/\(store.habits.count) Done")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            // show empty state if no habits, otherwise show the list
            if store.habits.isEmpty {
                VStack(spacing: 12) {
                    Text("No habits yet!")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Tap + to add your first habit")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(store.habits) { habit in
                        HabitRow(habit: habit)
                    }
                    // swipe left on a habit to delete it
                    .onDelete { indexSet in
                        indexSet.forEach { i in
                            store.deleteHabit(store.habits[i])
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }

            // button to open the add habit sheet
            Button {
                showAddHabit = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Habit")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                        .foregroundColor(.gray)
                )
                .padding()
            }
        }
        .navigationTitle("Today")
        .sheet(isPresented: $showAddHabit) {
            AddHabitView()
        }
    }
}

// each row in the habit list
struct HabitRow: View {
    @EnvironmentObject var store: HabitStore
    let habit: Habit

    var body: some View {
        HStack(spacing: 12) {

            // habit icon
            Image(systemName: habit.icon)
                .font(.system(size: 20))
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.body)
                    .fontWeight(.medium)
                // show build or quit badge
                Text(habit.type.rawValue)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(habit.type == .quit ? .red : .green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(habit.type == .quit ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                    .cornerRadius(4)
                Text("\(habit.isCompletedToday ? habit.goal : 0)/\(habit.goal) \(habit.unit.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()

            // tap to mark habit as done or not done
            Button {
                store.toggleToday(habit)
            } label: {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26))
                    .foregroundColor(habit.isCompletedToday ? .black : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(HabitStore())
}
