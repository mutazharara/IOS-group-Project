//
//  Untitled.swift
//  Momentum
//
//  Created by Mutaz on 9/5/2026.
//
import SwiftUI

struct HabitTimerSheet: View {
    @EnvironmentObject var store: HabitStore
    @Environment(\.dismiss) var dismiss

    let habit: Habit

    @State private var timeRemaining: Int
    @State private var timerRunning = false
    @State private var isFinished = false
    @State private var timer: Timer?
    
    @State private var animateCheck = false

    private let accent = Color.orange
    private let softBackground = Color(red: 0.97, green: 0.97, blue: 0.94)

    init(habit: Habit) {
        self.habit = habit
        let seconds = habit.unit == .hours ? habit.goal * 3600 : habit.goal * 60
        _timeRemaining = State(initialValue: seconds)
    }

    var alreadyCompleted: Bool {
        habit.isCompletedToday || isFinished
    }

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            
            // Header
            HStack(spacing: 14) {
                Image(systemName: habit.icon)
                    .font(.system(size: 24))
                    .foregroundColor(accent)
                    .frame(width: 58, height: 58)
                    .background(accent.opacity(0.12))
                    .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Goal: \(habit.goal) \(habit.unit.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Timer / Completed State
            ZStack {
                if alreadyCompleted {
                    Circle()
                    .stroke(Color.green, lineWidth: 12)
                    .frame(width: 150, height: 150)
                } else{
                    Circle()
                    .stroke(Color.gray.opacity(0.18), lineWidth: 12)
                    .frame(width: 150, height: 150)
                }

                if alreadyCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(.green)
                        .scaleEffect(animateCheck ? 1 : 0.5)
                        .opacity(animateCheck ? 1 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animateCheck)
                } else {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(accent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))

                    Text(timeText())
                        .font(.system(size: 34, weight: .bold))
                }
            }

            if alreadyCompleted {
                    Text("Completed, keep up the good work!")
                        .font(.headline)
                        .foregroundColor(.green)
            }

            if !alreadyCompleted {
                VStack(spacing: 12) {
                    Button {
                        timerRunning ? pauseTimer() : startTimer()
                    } label: {
                        Text(timerRunning ? "Pause Timer" : "Start Timer")
                            .font(.headline)
                            .foregroundColor(timerRunning ? accent : .white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(timerRunning ? accent.opacity(0.30) : accent)
                            .cornerRadius(18)
                    }

                    Button {
                        store.skipToday(habit)
                        dismiss()
                    } label: {
                        Text("Skip")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
            } else {
                VStack(spacing: 12) {
                

                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(18)
                    }
                    
                    
                    Button {
                        store.toggleToday(habit)
                        dismiss()
                    } label: {
                        Text("Undo")
                            .font(.headline)
                            .foregroundColor(.gray)
                            
                    }
                    
                }
            }
        }
        .padding(12)
        .onDisappear {
            timer?.invalidate()
        }
        .onAppear {
            if alreadyCompleted {
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                       animateCheck = true
                   }
               } else {
                   animateCheck = false
               }
        }
    }

    var totalSeconds: Int {
        habit.unit == .hours ? habit.goal * 3600 : habit.goal * 60
    }

    var progress: CGFloat {
        guard totalSeconds > 0 else { return 0 }
        return CGFloat(totalSeconds - timeRemaining) / CGFloat(totalSeconds)
    }

    func startTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                pauseTimer()
                isFinished = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateCheck = true
                }

                if !habit.isCompletedToday {
                    store.toggleToday(habit)
                }
            }
        }
    }

    func pauseTimer() {
        timerRunning = false
        timer?.invalidate()
    }

    func timeText() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    HabitTimerSheet(
        habit: Habit(
            name: "Meditate",
            icon: "moon.fill",
            type: .build,
            frequency: .daily,
            goal: 20,
            unit: .minutes,
            reminderTime: Date()
        )
    )
    .environmentObject(HabitStore())
}
