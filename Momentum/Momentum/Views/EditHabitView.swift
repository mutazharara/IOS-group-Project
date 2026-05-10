//
//  EditHabitView.swift
//  Momentum
//
//  Created by Mutaz on 3/5/2026.
//

import SwiftUI
import JDStatusBarNotification

struct EditHabitView: View {
    @EnvironmentObject var store: HabitStore
    @Environment(\.dismiss) var dismiss

    let habit: Habit

    @State private var name: String
    @State private var selectedIcon: String
    @State private var habitType: HabitType
    @State private var frequency: HabitFrequency
    @State private var goal: String
    @State private var unit: HabitUnit
    @State private var reminderTime: Date
    @State private var showError = false

    private let accent = Color.orange
    private let softBackground = Color(red: 0.97, green: 0.97, blue: 0.94)

    init(habit: Habit) {
        self.habit = habit
        _name = State(initialValue: habit.name)
        _selectedIcon = State(initialValue: habit.icon)
        _habitType = State(initialValue: habit.type)
        _frequency = State(initialValue: habit.frequency)
        _goal = State(initialValue: "\(habit.goal)")
        _unit = State(initialValue: habit.unit)
        _reminderTime = State(initialValue: habit.reminderTime)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle(icon: "pencil", title: "HABIT NAME")

                    TextField("Habit Name", text: $name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)

                    if showError {
                        Text("Please enter a valid habit name and goal")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(habitIcons, id: \.self) { icon in
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.system(size: 22))
                                        .foregroundColor(selectedIcon == icon ? .white : accent)
                                        .frame(width: 52, height: 52)
                                        .background(selectedIcon == icon ? accent : accent.opacity(0.12))
                                        .cornerRadius(16)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle(icon: "tag", title: "HABIT TYPE")

                    HStack(spacing: 10) {
                        ForEach(HabitType.allCases, id: \.self) { type in
                            Button {
                                habitType = type
                            } label: {
                                Text(type.rawValue)
                                    .fontWeight(.bold)
                                    .foregroundColor(habitType == type ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(habitType == type ? accent : Color(.systemGray6))
                                    .cornerRadius(16)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle(icon: "repeat", title: "FREQUENCY")

                    VStack(spacing: 10) {
                        ForEach(HabitFrequency.allCases, id: \.self) { f in
                            Button {
                                frequency = f
                            } label: {
                                HStack {
                                    Text(f.rawValue)
                                        .font(.headline)

                                    Spacer()

                                    if frequency == f {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .foregroundColor(frequency == f ? .white : .primary)
                                .padding()
                                .background(frequency == f ? accent : Color(.systemGray6))
                                .cornerRadius(14)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle(icon: "target", title: "GOAL")

                    HStack(spacing: 12) {
                        TextField("1", text: $goal)
                            .keyboardType(.numberPad)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding()
                            .frame(height: 52)
                            .background(Color(.systemGray6))
                            .cornerRadius(16)

                        Menu {
                            ForEach(HabitUnit.allCases, id: \.self) { u in
                                Button(u.rawValue) {
                                    unit = u
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(unit.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .lineLimit(1)

                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .frame(width: 95, height: 52)
                            .background(accent)
                            .cornerRadius(16)
                        }
                    }
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle(icon: "bell", title: "REMINDER TIME")

                    HStack {
                        DatePicker(
                            "",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()

                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(18)
                }
                .cardStyle()
            }
            .padding()
        }
        .background(softBackground.ignoresSafeArea())
        .navigationTitle("Edit Habit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Update") {
                    updateHabit()
                }
                .fontWeight(.bold)
                .foregroundColor(accent)
            }
        }
    }

    func updateHabit() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty || (Int(goal) ?? 0) <= 0 {
            showError = true
            return
        }

        var updatedHabit = habit
        updatedHabit.name = trimmed
        updatedHabit.icon = selectedIcon
        updatedHabit.type = habitType
        updatedHabit.frequency = frequency
        updatedHabit.goal = Int(goal) ?? 1
        updatedHabit.unit = unit
        updatedHabit.reminderTime = reminderTime

        store.updateHabit(updatedHabit)
        NotificationPresenter.shared.present(
            "✓ Habit updated successfully",
            includedStyle: .success,
            duration: 1.2
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }

    func sectionTitle(icon: String, title: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundColor(.secondary)
    }
}

#Preview {
    NavigationStack {
        EditHabitView(
            habit: Habit(
                name: "Drink Water",
                icon: "drop.fill",
                type: .build,
                frequency: .daily,
                goal: 8,
                unit: .glasses,
                reminderTime: Date()
            )
        )
        .environmentObject(HabitStore())
    }
}
