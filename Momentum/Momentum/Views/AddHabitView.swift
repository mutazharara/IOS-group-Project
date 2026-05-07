//
//  AddHabitView.swift
//  Momentum
//
//  Created by Mutaz on 3/5/2026.
//

import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var store: HabitStore
    @Environment(\.dismiss) var dismiss

    // all the fields the user fills in
    @State private var name = ""
    @State private var selectedIcon = habitIcons[0]
    @State private var habitType: HabitType = .build
    @State private var frequency: HabitFrequency = .daily
    @State private var goal = "1"
    @State private var unit: HabitUnit = .times
    @State private var reminderTime = Date()
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // habit name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Habit Name")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        TextField("e.g. Drink Water", text: $name)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray3), lineWidth: 1)
                            )

                        // show error if name is empty or goal is 0
                        if showError {
                            Text("Please enter a valid habit name and goal")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // icon picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Icon")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(habitIcons, id: \.self) { icon in
                                    Button {
                                        selectedIcon = icon
                                    } label: {
                                        Image(systemName: icon)
                                            .font(.system(size: 20))
                                            .frame(width: 44, height: 44)
                                            .background(selectedIcon == icon ? Color.black : Color(.systemGray6))
                                            .foregroundColor(selectedIcon == icon ? .white : .primary)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color(.systemGray3), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // build or quit toggle
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Type")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        HStack(spacing: 0) {
                            ForEach(HabitType.allCases, id: \.self) { type in
                                Button {
                                    habitType = type
                                } label: {
                                    Text(type.rawValue)
                                        .font(.system(size: 15, weight: .medium))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 11)
                                        .background(habitType == type ? Color.black : Color.clear)
                                        .foregroundColor(habitType == type ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray3), lineWidth: 1)
                        )
                    }

                    // how often the habit repeats
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Repeat")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Menu {
                            ForEach(HabitFrequency.allCases, id: \.self) { f in
                                Button(f.rawValue) { frequency = f }
                            }
                        } label: {
                            HStack {
                                Text(frequency.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14))
                            }
                            .padding(14)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray3), lineWidth: 1)
                            )
                        }
                    }

                    HStack(alignment: .top, spacing: 12) {

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            TextField("1", text: $goal)
                                .keyboardType(.numberPad)
                                .padding(14)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray3), lineWidth: 1)
                                )
                        }
                        .frame(maxWidth: .infinity)

                        // what unit the goal is measured in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unit")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Menu {
                                ForEach(HabitUnit.allCases, id: \.self) { u in
                                    Button(u.rawValue) { unit = u }
                                }
                            } label: {
                                HStack {
                                    Text(unit.rawValue)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 14))
                                }
                                .padding(14)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray3), lineWidth: 1)
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // reminder time picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reminder")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        HStack {
                            DatePicker(
                                "",
                                selection: $reminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            Spacer()
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                        }
                        .padding(14)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray3), lineWidth: 1)
                        )
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // create button at bottom
                Button {
                    createHabit()
                } label: {
                    Text("Create Habit")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .padding(.top, 8)
                .background(Color(.systemGroupedBackground))
            }
        }
    }

    func createHabit() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)

        // make sure name is not empty and goal is more than 0
        if trimmed.isEmpty || (Int(goal) ?? 0) <= 0 {
            showError = true
            return
        }

        let newHabit = Habit(
            name: trimmed,
            icon: selectedIcon,
            type: habitType,
            frequency: frequency,
            goal: Int(goal) ?? 1,
            unit: unit,
            reminderTime: reminderTime
        )

        store.addHabit(newHabit)
        dismiss()
    }
}

#Preview {
    AddHabitView()
        .environmentObject(HabitStore())
}
