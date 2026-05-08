//
//  StatsView.swift
//  Momentum
//
//  Created by Andrew on 8/5/2026.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: HabitStore

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // overall summary cards
                HStack(spacing: 12) {
                    StatCard(
                        title: "Today",
                        value: "\(store.doneCount)/\(store.habits.count)",
                        subtitle: "Completed",
                        icon: "checkmark.circle.fill"
                    )
                    StatCard(
                        title: "Best Streak",
                        value: "\(bestStreakAllHabits())",
                        subtitle: "Days",
                        icon: "flame.fill"
                    )
                }

                HStack(spacing: 12) {
                    StatCard(
                        title: "Total Habits",
                        value: "\(store.habits.count)",
                        subtitle: "Active",
                        icon: "list.bullet"
                    )
                    StatCard(
                        title: "All Time",
                        value: "\(totalCompletions())",
                        subtitle: "Completions",
                        icon: "trophy.fill"
                    )
                }

                // last 7 days bar chart
                if !store.habits.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Last 7 Days")
                            .font(.headline)
                            .padding(.horizontal)

                        WeeklyBarChart(habits: store.habits)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)
                }

                // per habit breakdown
                if !store.habits.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Habit Breakdown")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.bottom, 12)

                        ForEach(store.habits) { habit in
                            HabitStatRow(habit: habit)
                            if habit.id != store.habits.last?.id {
                                Divider().padding(.leading, 56)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)
                }

                if store.habits.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No habits yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Add habits to see your stats here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }

                Spacer(minLength: 20)
            }
            .padding(.top, 16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Statistics")
    }

    // total completions across all habits ever
    func totalCompletions() -> Int {
        store.habits.reduce(0) { $0 + $1.completedDates.count }
    }

    // find the longest current streak across all habits
    func bestStreakAllHabits() -> Int {
        store.habits.map { currentStreak(for: $0) }.max() ?? 0
    }
}

// streak calculation helper
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

// completion rate over all time for a habit
func completionRate(for habit: Habit) -> Double {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"

    // figure out how many days since first completion
    guard let firstDateStr = habit.completedDates.sorted().first,
          let firstDate = formatter.date(from: firstDateStr) else {
        return 0.0
    }

    let daysSinceFirst = Calendar.current.dateComponents([.day], from: firstDate, to: Date()).day ?? 0
    let totalDays = max(daysSinceFirst + 1, 1)
    return Double(habit.completedDates.count) / Double(totalDays)
}

// summary stat card
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// weekly bar chart showing completions per day
struct WeeklyBarChart: View {
    let habits: [Habit]

    private var last7Days: [(label: String, count: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

        return (0..<7).reversed().map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
            let dateStr = formatter.string(from: date)
            let count = habits.filter { $0.completedDates.contains(dateStr) }.count
            return (label: dayFormatter.string(from: date), count: count)
        }
    }

    private var maxCount: Int {
        max(habits.count, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(last7Days, id: \.label) { day in
                VStack(spacing: 4) {
                    Text("\(day.count)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .opacity(day.count > 0 ? 1 : 0)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(day.count == maxCount ? Color.black : Color(.systemGray4))
                        .frame(
                            height: day.count == 0
                                ? 4
                                : max(4, CGFloat(day.count) / CGFloat(maxCount) * 80)
                        )

                    Text(day.label)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 110)
    }
}

// per-habit stat row
struct HabitStatRow: View {
    let habit: Habit

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: habit.icon)
                .font(.system(size: 18))
                .frame(width: 40, height: 40)
                .background(Color(.systemGray6))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.body)
                    .fontWeight(.medium)

                // completion progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(.systemGray5))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.black)
                            .frame(
                                width: geo.size.width * min(completionRate(for: habit), 1.0),
                                height: 6
                            )
                    }
                }
                .frame(height: 6)

                Text("\(habit.completedDates.count) total · \(Int(completionRate(for: habit) * 100))% rate")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(currentStreak(for: habit))")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                HStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Text("streak")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
    .environmentObject(HabitStore())
}
