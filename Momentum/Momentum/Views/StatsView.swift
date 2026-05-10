//
//  StatsView.swift
//  Momentum
//
//  Created by Andrew on 8/5/2026.
//
import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: HabitStore

    private let accent = Color.orange
    private let softBackground = Color(red: 0.97, green: 0.97, blue: 0.94)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {

                if store.habits.isEmpty {
                    emptyState
                } else {
                    Text("Overview")
                        .font(.headline)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        StatCard(title: "Today", value: "\(store.doneCount)/\(store.habits.count)", subtitle: "Completed", icon: "checkmark.circle.fill", color: .green)

                        StatCard(title: "Skipped", value: "\(totalSkipped())", subtitle: "All time", icon: "xmark.circle.fill", color: .red)

                        StatCard(title: "Best Streak", value: "\(bestStreakAllHabits())", subtitle: "Days", icon: "flame.fill", color: accent)

                        StatCard(title: "Total", value: "\(totalCompletions())", subtitle: "Completions", icon: "trophy.fill", color: accent)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle(icon: "chart.bar.fill", title: "LAST 7 DAYS")
                        WeeklyBarChart(habits: store.habits)
                    }
                    .cardStyle()

                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle(icon: "list.bullet", title: "HABIT BREAKDOWN")

                        ForEach(store.habits) { habit in
                            HabitStatRow(habit: habit)
                        }
                    }
                    .cardStyle()
                }
            }
            .padding()
        }
        .background(softBackground.ignoresSafeArea())
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }

    var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 48))
                .foregroundColor(accent)

            Text("No statistics yet")
                .font(.title3)
                .fontWeight(.bold)

            Text("Add and complete habits to see your progress here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    func sectionTitle(icon: String, title: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundColor(.secondary)
    }

    func totalCompletions() -> Int {
        store.habits.reduce(0) { $0 + $1.completedDates.count }
    }

    func totalSkipped() -> Int {
        store.habits.reduce(0) { $0 + $1.skippedDates.count }
    }

    func bestStreakAllHabits() -> Int {
        store.habits.map { currentStreak(for: $0) }.max() ?? 0
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)

            Text(value)
                .font(.system(size: 30, weight: .bold, design: .rounded))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct WeeklyBarChart: View {
    let habits: [Habit]
    private let accent = Color.orange

    private var last7Days: [(label: String, count: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

        return (0..<7).reversed().map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
            let dateStr = formatter.string(from: date)
            let count = habits.filter { $0.completedDates.contains(dateStr) }.count
            return (dayFormatter.string(from: date), count)
        }
    }

    private var maxCount: Int {
        max(habits.count, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(last7Days, id: \.label) { day in
                VStack(spacing: 6) {
                    Text("\(day.count)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .opacity(day.count > 0 ? 1 : 0)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(day.count > 0 ? accent : Color.gray.opacity(0.18))
                        .frame(
                            width: 24,
                            height: day.count == 0 ? 8 : max(12, CGFloat(day.count) / CGFloat(maxCount) * 90)
                        )

                    Text(day.label.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 135)
    }
}

struct HabitStatRow: View {
    let habit: Habit
    private let accent = Color.orange

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: habit.icon)
                .font(.system(size: 22))
                .foregroundColor(accent)
                .frame(width: 52, height: 52)
                .background(accent.opacity(0.12))
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 6) {
                Text(habit.name)
                    .font(.headline)
                    .fontWeight(.bold)

                ProgressView(value: min(completionRate(for: habit), 1.0))
                    .tint(accent)

                Text("\(habit.completedDates.count) done · \(habit.skippedDates.count) skipped · \(Int(completionRate(for: habit) * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("\(currentStreak(for: habit))")
                    .font(.title3)
                    .fontWeight(.bold)

                Image(systemName: "flame.fill")
                    .foregroundColor(accent)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }
}

func currentStreak(for habit: Habit) -> Int {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"

    var streak = 0
    var date = Date()

    while true {
        let dateStr = formatter.string(from: date)

        if habit.completedDates.contains(dateStr) {
            streak += 1
            date = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        } else {
            break
        }
    }

    return streak
}

func completionRate(for habit: Habit) -> Double {
    let total = habit.completedDates.count + habit.skippedDates.count
    guard total > 0 else { return 0 }
    return Double(habit.completedDates.count) / Double(total)
}

#Preview {
    NavigationStack {
        StatsView()
            .environmentObject(HabitStore())
    }
}
