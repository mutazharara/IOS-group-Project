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

struct HabitDetailView: View {
    @EnvironmentObject var store: HabitStore
    @Environment(\.dismiss) var dismiss

    let habit: Habit

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
                            .font(.system(size: 36))
                            .foregroundColor(accent)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(habit.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("\(habit.type.rawValue) Habit")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.green.opacity(0.14))
                                .cornerRadius(12)
                        }

                        Spacer()
                    }
                }
                .padding(22)
                .frame(maxWidth: .infinity)
                .background(cardColor)
                .cornerRadius(24)

                // Info Cards
                HStack(spacing: 12) {
                    smallInfoCard(icon: "target", title: "Goal", value: "\(habit.goal) \(habit.unit.rawValue)")
                    smallInfoCard(icon: "clock", title: "Frequency", value: habit.frequency.rawValue)
                    smallInfoCard(icon: "flame.fill", title: "Streak", value: "\(currentStreak())d")
                }

                // Schedule Card
                VStack(alignment: .leading, spacing: 14) {
                    sectionTitle(icon: "calendar", title: "SCHEDULE")

                    Text(formattedTime(habit.reminderTime))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(accent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(accent.opacity(0.12))
                        .cornerRadius(16)
                }
                .cardStyle()

                // Action Buttons
                HStack(spacing: 12) {
                    Button {
                        // skip logic can be added later
                    } label: {
                        Label("Skip", systemImage: "arrow.right")
                            .font(.headline)
                            .foregroundColor(accent)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(accent.opacity(0.12))
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
                            let future = isFuture(date)

                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(completed ? Color.green.opacity(0.18) : Color.white)
                                        .frame(width: 38, height: 38)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.gray.opacity(0.25), lineWidth: 1.5)
                                        )

                                    if completed {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.green)
                                    } else if !future {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.red.opacity(0.7))
                                    }
                                }

                                Image(systemName: "flame.fill")
                                    .font(.caption)
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
                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle(icon: "calendar", title: "CALENDAR")

                    Text(monthTitle())
                        .font(.headline)
                        .frame(maxWidth: .infinity)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16) {
                        ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }

                        ForEach(monthDates(), id: \.self) { date in
                            if Calendar.current.component(.month, from: date) == Calendar.current.component(.month, from: Date()) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(width: 38, height: 38)
                                    .background(isCompleted(on: date) ? Color.green.opacity(0.18) : Color.clear)
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
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

                    if habit.completedDates.isEmpty {
                        Text("No history yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(habit.completedDates.suffix(4).reversed(), id: \.self) { date in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(historyDateText(date))
                                        .fontWeight(.semibold)

                                    Text("Completed")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }

                                Spacer()
                            }
                        }
                    }
                }
                .cardStyle()
            }
            .padding()
        }
        .background(softBackground.ignoresSafeArea())
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    
                    // Edit Button
                    Button("Edit") {
                        // navigate to EditHabitView later
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    
                    // Three Dots Menu
                    Menu {
                        Button(role: .destructive) {
                            store.deleteHabit(habit)
                            dismiss()
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

    func monthTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    func monthDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()

        guard let monthInterval = calendar.dateInterval(of: .month, for: today),
              let monthRange = calendar.range(of: .day, in: .month, for: today) else {
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

    func historyDateText(_ dateString: String) -> String {
        return dateString
    }
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
            "2026-05-06",
            "2026-05-07"
        ]
    )

    let store = HabitStore()
    store.habits = [sampleHabit]

    return NavigationStack {
        HabitDetailView(habit: sampleHabit)
            .environmentObject(store)
    }
}
