//
//  HabitDetailView.swift
//  Momentum
//
//  Created by Mutaz on 3/5/2026.
//
//
//  HabitDetailView.swift
//  Momentum
//

import SwiftUI
import JDStatusBarNotification

struct HabitDetailView: View {
    @EnvironmentObject var store: HabitStore
    @Environment(\.dismiss) var dismiss
    @State private var displayedMonth = Date()

    let habit: Habit
    var habitTagColor: Color {
        habit.type == .quit ? .red : .green
    }
    let weekLabels = ["M", "T", "W", "T", "F", "S", "S"]
    private let accent = Color.orange
    private let softBackground = Color(red: 0.97, green: 0.97, blue: 0.94)
    private let cardColor = Color.white

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                // Main Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 14) {
                        Image(systemName: habit.icon)
                            .font(.system(size: 26))
                            .foregroundColor(.orange)
                            .frame(width: 58, height: 58)
                            .background(Color.orange.opacity(0.12))
                            .cornerRadius(16)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(habit.name)
                                .font(.title3)
                                .fontWeight(.bold)

                            HStack(spacing: 4) {
                                Label(formattedTime(habit.reminderTime), systemImage: "clock")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(accent)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(accent.opacity(0.14))
                                    .cornerRadius(12)
                            }
                        }

                        Spacer()
                    }
                }
                .padding(22)
                .frame(maxWidth: .infinity)
                .background(cardColor)
                .cornerRadius(24)
                
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button {
                        store.skipToday(habit)
                    } label: {
                        Label(  isSkippedToday() ? "Undo Skip" : "Skip",
                                systemImage: isSkippedToday() ? "arrow.uturn.backward" : "arrow.right" )
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.12))
                            .cornerRadius(18)
                    }

                    Button {
                        store.toggleToday(habit)
                    } label: {
                        Label(
                            habit.isCompletedToday ? "Undo" : "Complete",
                            systemImage: habit.isCompletedToday ? "arrow.uturn.backward" : "checkmark.circle.fill"
                        )
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.14))
                        .cornerRadius(18)
                    }
                }

                // Info Cards
                HStack(spacing: 12) {
                    smallInfoCard(icon: "target", title: "Goal", value: "\(habit.goal) \(habit.unit.rawValue)")
                    smallInfoCard(icon: "clock", title: "Frequency", value: habit.frequency.rawValue)
                    smallInfoCard(icon: "flame", title: "Streak", value: "\(currentStreak())d")
                }



                // Week Streak Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Label("\(currentStreak()) Day Streak", systemImage: "flame.fill")
                            .font(.headline)
                            .foregroundColor(accent)

                        Spacer()

                        Text("This Week")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        ForEach(Array(currentWeekDates.enumerated()), id: \.offset) { _, date in
                            let completed = isCompleted(on: date)

                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(completed ? Color.green.opacity(0.18) :
                                                (isSkipped(on: date) || isMissed(date)) ? Color.red.opacity(0.18) :
                                                Color.white)
                                        .frame(width: 38, height: 38)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.gray.opacity(0.25), lineWidth: 1.5)
                                        )

                                    if completed {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    } else if isSkipped(on: date) || isMissed(date) {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.red)
                                    }
                                }

                                Image(systemName: "flame.fill")
                                    .font(.headline)
                                    .foregroundColor(completed ? accent : .gray.opacity(0.5))

                                Text(dayShort(for: date))
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .cardStyle()

                // Calendar Card
                VStack(alignment: .leading, spacing: 18) {
                    sectionTitle(icon: "calendar", title: "CALENDAR")

                    HStack {
                        Button {
                            changeMonth(by: -1)
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(accent)
                                .font(.headline)
                        }

                        Spacer()

                        Text(monthTitle(for: displayedMonth))
                            .font(.headline)
                            .fontWeight(.bold)

                        Spacer()

                        Button {
                            changeMonth(by: 1)
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(accent)
                                .font(.headline)
                        }
                    }

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 7),
                        spacing: 14
                    ) {
                        
                        ForEach(Array(weekLabels.enumerated()), id: \.offset) { _, day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }

                        ForEach(monthDates(for: displayedMonth), id: \.self) { date in
                            let isCurrentMonth =
                                Calendar.current.component(.month, from: date) ==
                                Calendar.current.component(.month, from: displayedMonth)

                            let completed = isCompleted(on: date)
                            let skipped = isSkipped(on: date)
                            let today = Calendar.current.isDateInToday(date)

                            if isCurrentMonth {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            today ? accent :
                                            completed ? Color.green.opacity(0.18) :
                                            (skipped || isMissed(date)) ? Color.red.opacity(0.16) :
                                            Color.clear
                                        )
                                        .frame(width: 38, height: 38)

                                    VStack(spacing: 2) {
                                        Text("\(Calendar.current.component(.day, from: date))")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(today ? .white : .primary)

                                        if completed {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(today ? .white : .green)
                                        } else if skipped || isMissed(date) {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(today ? .white : .red)
                                        }
                                    }
                                }
                            } else {
                                Text("")
                                    .frame(width: 38, height: 38)
                            }
                        }
                    }
                }
                .cardStyle()

                // History Card
                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle(icon: "clock.arrow.circlepath", title: "HISTORY")

                    let historyItems = combinedHistory()

                    if historyItems.isEmpty {
                        Text("No history yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(historyItems.prefix(6), id: \.id) { item in
                            HStack(spacing: 12) {
                                Image(systemName: item.status == "Completed" ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(item.status == "Completed" ? .green : .red)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(historyDateText(item.date))
                                        .fontWeight(.semibold)

                                    Text(item.status)
                                        .font(.caption)
                                        .foregroundColor(item.status == "Completed" ? .green : .red)
                                }

                                Spacer()
                            }
                        }
                    }
                }
                .cardStyle()
            }
            .padding()
            .padding(.bottom, 18)
        }
        .background(softBackground)
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 0)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    
                    // Edit Button
                    NavigationLink {
                        EditHabitView(habit: habit)
                    } label: {
                        Text("Edit")
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    // Three Dots Menu
                    Menu {
                        Button(role: .destructive) {
                            store.deleteHabit(habit)
                            NotificationPresenter.shared.present(
                                "✓ Habit deleted successfully",
                                includedStyle: .success,
                                duration: 1.2
                            )

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                dismiss()
                            }
                        } label: {
                            Label("Delete Habit", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.orange)
                    }
                }
                .padding(.vertical, 6)
                .cornerRadius(16)
            }
        }
    }
    

    func smallInfoCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(accent)

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(cardColor)
        .cornerRadius(18)
    }

    func sectionTitle(icon: String, title: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundColor(.secondary)
    }

    var currentWeekDates: [Date] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else {
            return []
        }

        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekInterval.start)
        }
    }

    func isCompleted(on date: Date) -> Bool {
        habit.completedDates.contains(dateString(date))
    }

    func isFuture(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
    }

    func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func dayShort(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter.string(from: date).uppercased()
    }

    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func currentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0

        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }

            if isCompleted(on: date) {
                streak += 1
            } else if i > 0 {
                break
            }
        }

        return streak
    }
    
    func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    func monthDates(for date: Date) -> [Date] {
        let calendar = Calendar.current

        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthRange = calendar.range(of: .day, in: .month, for: date) else {
            return []
        }

        let firstDay = monthInterval.start
        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingEmptyDays = (weekday + 5) % 7

        let startDate = calendar.date(byAdding: .day, value: -leadingEmptyDays, to: firstDay) ?? firstDay

        return (0..<(monthRange.count + leadingEmptyDays)).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startDate)
        }
    }
    
    func isSkipped(on date: Date) -> Bool {
        habit.skippedDates.contains(dateString(date))
    }

    func historyDateText(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }

        return dateString
    }
    
    func isMissed(_ date: Date) -> Bool {
        let calendar = Calendar.current

        let today = calendar.startOfDay(for: Date())
        let checkDate = calendar.startOfDay(for: date)
        let created = calendar.startOfDay(for: habit.createdDate)

        // Only dates after habit was created can be missed
        return checkDate >= created &&
               checkDate < today &&
               !isCompleted(on: date) &&
               !isSkipped(on: date)
    }
    
    func isSkippedToday() -> Bool {
        habit.skippedDates.contains(dateString(Date()))
    }
    
    func combinedHistory() -> [HistoryItem] {
        let completed = habit.completedDates.map {
            HistoryItem(date: $0, status: "Completed")
        }

        let skipped = habit.skippedDates.map {
            HistoryItem(date: $0, status: "Skipped")
        }

        return (completed + skipped).sorted {
            $0.date > $1.date
        }
    }
    
    
}

struct HistoryItem: Identifiable {
    let id = UUID()
    let date: String
    let status: String
}

extension View {
    func cardStyle() -> some View {
        self
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(24)
    }
}

#Preview {
    let sampleHabit = Habit(
        name: "Read 10 pages",
        icon: "book.fill",
        type: .build,
        frequency: .daily,
        goal: 10,
        unit: .pages,
        reminderTime: Date(),
        completedDates: [
            "2026-05-04",
            "2026-05-05",
            "2026-05-07"
        ],
        skippedDates: ["2026-05-06"],
        createdDate: Date()
    )

    let store = HabitStore()
    store.habits = [sampleHabit]

    return NavigationStack {
        HabitDetailView(habit: sampleHabit)
            .environmentObject(store)
    }
}
