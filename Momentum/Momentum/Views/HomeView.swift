//
//  HomeView.swift
//  Momentum
//
//  Created by Mutaz on 3/5/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: HabitStore
    @State private var searchText = ""
    @State private var selectedFilter: HabitFilter = .all
    

    enum HabitFilter: String, CaseIterable {
        case all = "All"
        case build = "Build Habits"
        case quit = "Quit Habits"
    }

    var filteredHabits: [Habit] {
        store.habits.filter { habit in
            let matchesSearch = searchText.isEmpty ||
            habit.name.lowercased().contains(searchText.lowercased())

            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .build:
                matchesFilter = habit.type == .build
            case .quit:
                matchesFilter = habit.type == .quit
            }

            return matchesSearch && matchesFilter
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(HabitFilter.allCases, id: \.self) { filter in
                            Button {
                                selectedFilter = filter
                            } label: {
                                Group {
                                    if filter == .all {
                                        Label(filter.rawValue, systemImage: "rectangle.grid.2x2")
                                    } else {
                                        Text(filter.rawValue)
                                    }
                                }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(selectedFilter == filter ? .white : .secondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == filter ? Color.orange : Color.white)
                                    .cornerRadius(18)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    // Your Activity
                    Text("Your activity")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        activityCard(icon: "calendar", number: "\(store.habits.count)", title: "Today")
                        
                        activityCard(icon: "arrowshape.turn.up.forward", number: "\(skippedCount())", title: "Skipped")
                        
                        activityCard(icon: "flame", number: "\(store.doneCount)", title: "Done")
                    }
                }
                // Today Section
                HStack {
                    Text("TODAY")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.gray.opacity(0.15))
                        .cornerRadius(10)

                    Text(formattedTodayDate())
                        .font(.title3)
                        .fontWeight(.bold)

                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.25))
                }

                // Habit List
                if filteredHabits.isEmpty {
                    VStack(spacing: 10) {
                        Text("No habits found")
                            .font(.headline)

                        Text("Tap + to add your first habit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else {
                    VStack(spacing: 14) {
                        ForEach(filteredHabits) { habit in
                            NavigationLink {
                                HabitDetailView(habit: habit)
                            } label: {
                                HabitCardRow(habit: habit)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.94).ignoresSafeArea())
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search habits...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AddHabitView()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.orange)
                }
            }
        }
    }

    func activityCard(icon: String, number: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.orange)

            Text(number)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(18)
    }

    func formattedTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    func skippedCount() -> Int {
        store.habits.reduce(0) { total, habit in
            total + habit.skippedDates.count
        }
    }
}

struct HabitCardRow: View {
    @EnvironmentObject var store: HabitStore
    let habit: Habit
    private let accent = Color.orange
    @State private var showTimerSheet = false

    var habitColor: Color {
        habit.type == .quit ? .red : .green
    }
    
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    
    func isSkippedToday(_ habit: Habit) -> Bool {
        habit.skippedDates.contains(todayString())
    }
    
    func statusText(for habit: Habit) -> String {
        if habit.isCompletedToday {
            return "Done!"
        } else if isSkippedToday(habit) {
            return "Skipped"
        } else if isMissedToday(habit) {
            return "Missed"
        } else {
            return formattedTime(habit.reminderTime)
        }
    }

    func statusIcon(for habit: Habit) -> String {
        if habit.isCompletedToday {
            return "checkmark.circle.fill"
        } else if isSkippedToday(habit) {
            return "xmark.circle.fill"
        } else if isMissedToday(habit) {
            return "exclamationmark.circle.fill"
        } else {
            return "clock"
        }
    }

    func statusColor(for habit: Habit) -> Color {
        if habit.isCompletedToday {
            return .green
        } else if isSkippedToday(habit) || isMissedToday(habit) {
            return .red
        } else {
            return .orange
        }
    }

    func isMissedToday(_ habit: Habit) -> Bool {
        return false
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: habit.icon)
                .font(.system(size: 26))
                .foregroundColor(.orange)
                .frame(width: 58, height: 58)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 6) {
                Text(habit.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor( habit.isCompletedToday ? .gray :
                                        isSkippedToday(habit) ? .red :
                                        .primary)
                    .strikethrough(habit.isCompletedToday, color: .gray)

                HStack(spacing: 6) {
                    Label(statusText(for: habit), systemImage: statusIcon(for: habit))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor(for: habit))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(statusColor(for: habit).opacity(0.14))
                        .cornerRadius(12)
                }
            }

            Spacer()
            

            Button {
                if habit.unit == .minutes || habit.unit == .hours {
                    showTimerSheet = true
                } else {
                    store.toggleToday(habit)
                }
            } label: {
                Image(systemName:
                    habit.isCompletedToday ? "checkmark.circle.fill" :
                    isSkippedToday(habit) ? "xmark.circle.fill" :
                    "circle"
                )
                .font(.system(size: 28))
                .foregroundColor(
                    habit.isCompletedToday ? .green :
                    isSkippedToday(habit) ? .red :
                    .gray.opacity(0.6)
                )
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .background(Color.white)
        .sheet(isPresented: $showTimerSheet) {
            HabitTimerSheet(habit: habit)
                .environmentObject(store)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .cornerRadius(22)
        .opacity(habit.isCompletedToday || isSkippedToday(habit) ? 0.8 : 1)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(HabitStore())
    }
}
