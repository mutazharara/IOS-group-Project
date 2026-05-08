//
//  TimerView.swift
//  Momentum
//
//  Created by Andrew on 8/5/2026.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var store: HabitStore
    @StateObject private var timerManager = TimerManager()

    // which habit this timer session is for (optional)
    @State private var selectedHabit: Habit? = nil
    @State private var showHabitPicker = false

    // time picker values for countdown setup
    @State private var pickerMinutes = 5
    @State private var pickerSeconds = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {

                // mode toggle: countdown vs stopwatch
                ModeToggle(selectedMode: timerManager.mode) { newMode in
                    timerManager.switchMode(to: newMode)
                    if newMode == .countdown {
                        timerManager.setCountdown(minutes: pickerMinutes, seconds: pickerSeconds)
                    }
                }
                .padding(.top, 8)

                // main timer ring
                TimerRing(
                    timerManager: timerManager,
                    onTap: handleRingTap
                )

                // countdown time picker (only shown in countdown + idle)
                if timerManager.mode == .countdown && timerManager.state == .idle {
                    CountdownPicker(minutes: $pickerMinutes, seconds: $pickerSeconds) {
                        timerManager.setCountdown(minutes: pickerMinutes, seconds: pickerSeconds)
                    }
                }

                // habit link button
                Button {
                    showHabitPicker = true
                } label: {
                    HStack(spacing: 10) {
                        if let habit = selectedHabit {
                            Image(systemName: habit.icon)
                                .font(.system(size: 16))
                                .frame(width: 32, height: 32)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            Text(habit.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        } else {
                            Image(systemName: "link")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Text("Link to a Habit")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal)

                // mark habit complete button (visible when timer finished or running)
                if let habit = selectedHabit,
                   (timerManager.state == .finished || timerManager.state == .running || timerManager.state == .paused) {
                    Button {
                        store.toggleToday(habit)
                    } label: {
                        HStack {
                            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                            Text(habit.isCompletedToday ? "Marked Complete!" : "Mark \(habit.name) as Done")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(habit.isCompletedToday ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(habit.isCompletedToday ? Color.black : Color(.systemGray5))
                        .cornerRadius(14)
                    }
                    .padding(.horizontal)
                    .animation(.easeInOut, value: habit.isCompletedToday)
                }

                Spacer(minLength: 20)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Timer")
        .sheet(isPresented: $showHabitPicker) {
            HabitPickerSheet(selectedHabit: $selectedHabit)
        }
    }

    func handleRingTap() {
        switch timerManager.state {
        case .idle:
            if timerManager.mode == .countdown {
                timerManager.setCountdown(minutes: pickerMinutes, seconds: pickerSeconds)
            }
            timerManager.start()
        case .running:
            timerManager.pause()
        case .paused:
            timerManager.resume()
        case .finished:
            timerManager.reset()
            if timerManager.mode == .countdown {
                timerManager.setCountdown(minutes: pickerMinutes, seconds: pickerSeconds)
            }
        }
    }
}

// MARK: - Mode Toggle

struct ModeToggle: View {
    let selectedMode: TimerMode
    let onChange: (TimerMode) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach([TimerMode.countdown, TimerMode.stopwatch], id: \.self) { mode in
                Button {
                    onChange(mode)
                } label: {
                    Text(mode == .countdown ? "Countdown" : "Stopwatch")
                        .font(.system(size: 15, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedMode == mode ? Color.black : Color.clear)
                        .foregroundColor(selectedMode == mode ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// MARK: - Timer Ring

struct TimerRing: View {
    @ObservedObject var timerManager: TimerManager
    let onTap: () -> Void

    private var ringColor: Color {
        switch timerManager.state {
        case .finished: return .green
        case .running:  return .black
        default:        return Color(.systemGray4)
        }
    }

    private var centerLabel: String {
        switch timerManager.state {
        case .idle:     return timerManager.mode == .countdown ? "Tap to Start" : "Tap to Start"
        case .running:  return "Tap to Pause"
        case .paused:   return "Tap to Resume"
        case .finished: return "Done! Tap to Reset"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // background ring
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                    .frame(width: 220, height: 220)

                // progress ring (countdown only)
                if timerManager.mode == .countdown {
                    Circle()
                        .trim(from: 0, to: timerManager.progress())
                        .stroke(ringColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timerManager.progress())
                }

                // stopwatch fills solid ring when running
                if timerManager.mode == .stopwatch && timerManager.state == .running {
                    Circle()
                        .stroke(ringColor.opacity(0.3), lineWidth: 12)
                        .frame(width: 220, height: 220)
                }

                // time text
                VStack(spacing: 6) {
                    Text(timerManager.formattedTime())
                        .font(.system(size: 52, weight: .bold, design: .monospaced))
                        .contentTransition(.numericText())

                    Text(centerLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                onTap()
            }

            // reset button (shown when not idle)
            if timerManager.state != .idle {
                Button {
                    timerManager.reset()
                } label: {
                    Text("Reset")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Countdown Picker

struct CountdownPicker: View {
    @Binding var minutes: Int
    @Binding var seconds: Int
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Set Duration")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal)

            HStack(spacing: 0) {
                Picker("Minutes", selection: $minutes) {
                    ForEach(0..<60) { m in
                        Text("\(m) min").tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .onChange(of: minutes) { onChange() }

                Picker("Seconds", selection: $seconds) {
                    ForEach(0..<60) { s in
                        Text("\(s) sec").tag(s)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .onChange(of: seconds) { onChange() }
            }
            .frame(height: 120)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}

// MARK: - Habit Picker Sheet

struct HabitPickerSheet: View {
    @EnvironmentObject var store: HabitStore
    @Binding var selectedHabit: Habit?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                // option to clear the selection
                Button {
                    selectedHabit = nil
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.secondary)
                        Text("No Habit")
                            .foregroundColor(.secondary)
                        Spacer()
                        if selectedHabit == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black)
                        }
                    }
                }
                .buttonStyle(.plain)

                ForEach(store.habits) { habit in
                    Button {
                        selectedHabit = habit
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: habit.icon)
                                .font(.system(size: 16))
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            Text(habit.name)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedHabit?.id == habit.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Link Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TimerView()
    }
    .environmentObject(HabitStore())
}
