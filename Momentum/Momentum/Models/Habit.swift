//
//  Habit.swift
//  Momentum
//
//  Created by Mutaz on 3/5/2026.
//

import Foundation
import SwiftUI
import Combine

// habit type
enum HabitType: String, CaseIterable, Codable {
    case build = "Build"
    case quit = "Quit"
}

// how often the habit repeats
enum HabitFrequency: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

// unit for the habit goal
enum HabitUnit: String, CaseIterable, Codable {
    case times   = "times"
    case pages   = "pages"
    case minutes = "min"
    case hours   = "hr"
    case glasses = "glasses"
    case km      = "km"
    case steps   = "steps"
}

// this is the main habit model
struct Habit: Identifiable, Codable {
    var id = UUID()
    var name: String
    var icon: String
    var type: HabitType
    var frequency: HabitFrequency
    var goal: Int
    var unit: HabitUnit
    var reminderTime: Date
    var completedDates: [String] = []

    // get today's date as a string like "2026-05-04"
    var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    // check if the habit is already done today
    var isCompletedToday: Bool {
        return completedDates.contains(todayString)
    }

    // mark habit as done or undo it
    mutating func toggleToday() {
        let today = todayString
        if completedDates.contains(today) {
            completedDates.removeAll { $0 == today }
        } else {
            completedDates.append(today)
        }
    }
}

// this class holds all our habits and updates the UI when things change
class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []

    // key to save data in UserDefaults
    private let key = "saved_habits"

    // when the app starts load any saved habits
    init() {
        load()
    }

    // count how many habits are done today
    var doneCount: Int {
        return habits.filter { $0.isCompletedToday }.count
    }

    // add a new habit, schedule its notification and save
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        NotificationManager.shared.scheduleNotification(for: habit)
        save()
    }

    // mark habit as done or not done for today
    func toggleToday(_ habit: Habit) {
        if let i = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[i].toggleToday()
            save()
        }
    }

    // delete a habit and cancel its notification
    func deleteHabit(_ habit: Habit) {
        NotificationManager.shared.cancelNotification(for: habit)
        habits.removeAll { $0.id == habit.id }
        save()
    }

    // update an existing habit and reschedule notification
    func updateHabit(_ habit: Habit) {
        if let i = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[i] = habit
            NotificationManager.shared.scheduleNotification(for: habit)
            save()
        }
    }

    // save all habits to UserDefaults so they dont disappear when app closes
    private func save() {
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // load habits from UserDefaults when app opens
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let savedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = savedHabits
        }
    }
}

// list of icons the user can pick from
let habitIcons = [
    "drop.fill", "book.fill", "moon.fill", "bolt.fill",
    "figure.walk", "heart.fill", "pencil", "flame.fill"
]
