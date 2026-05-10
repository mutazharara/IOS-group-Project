import SwiftUI
import JDStatusBarNotification

struct AddHabitView: View {
    @EnvironmentObject var store: HabitStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var selectedIcon = habitIcons[0]
    @State private var habitType: HabitType = .build
    @State private var frequency: HabitFrequency = .daily
    @State private var goal = "1"
    @State private var unit: HabitUnit = .times
    @State private var reminderTime = Date()
    @State private var showError = false
    @State private var showSuccessToast = false

    private let accent = Color.orange
    private let softBackground = Color(red: 0.97, green: 0.97, blue: 0.94)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    
                    // Habit Name Card
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
                        
                        // Icon Card
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
                        
                    }.cardStyle()
                   
                    
                    // Habit Type Card
                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle(icon: "tag", title: "HABIT TYPE")
                        HStack(spacing: 10) {
                            ForEach(HabitType.allCases, id: \.self) { type in
                                Button {
                                    habitType = type
                                } label: {
                                    HStack {
                                        Text(type.rawValue)
                                            .font(.headline)
                                    }
                                    .foregroundColor(habitType == type ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(habitType == type ? accent : Color(.systemGray6))
                                    .cornerRadius(14)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                    }.cardStyle()

                    
                    // FREQUENCY Card
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
                    
                    // Goal Card
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
                        
                    }.cardStyle()
                    
                    // Reminder Time Card
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
                        
                        
                    }.cardStyle()
                    
                }
                .padding()
            }
            .background(softBackground.ignoresSafeArea())
            .navigationTitle("Add New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        createHabit()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(accent)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(18)
                }
            }
        }
    }

    func sectionCard<Content: View>(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.secondary)

            content()
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(26)
    }

    func typeColor(_ type: HabitType) -> Color {
        type == .quit ? .red : .green
    }

    func createHabit() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)

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
        
        NotificationPresenter.shared.present(
            "✓ Habit created successfully",
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
    AddHabitView()
        .environmentObject(HabitStore())
}
