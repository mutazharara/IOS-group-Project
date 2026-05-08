//
//  TimerManager.swift
//  Momentum
//
//  Created by Andrew on 8/5/2026.
//

import Foundation
import Combine

enum TimerMode {
    case countdown
    case stopwatch
}

enum TimerState {
    case idle
    case running
    case paused
    case finished
}

class TimerManager: ObservableObject {

    // current elapsed/remaining seconds shown in UI
    @Published var displaySeconds: Int = 0

    // current state
    @Published var state: TimerState = .idle

    // mode (countdown from a set time, or stopwatch counting up)
    @Published var mode: TimerMode = .countdown

    // for countdown - the total duration the user set
    var countdownDuration: Int = 300   // default 5 min

    private var timer: AnyCancellable?
    private var startDate: Date?
    private var accumulatedSeconds: Int = 0

    // MARK: - Public Controls

    func start() {
        guard state != .running else { return }
        startDate = Date()
        state = .running

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pause() {
        guard state == .running else { return }
        accumulatedSeconds = currentRawSeconds()
        timer?.cancel()
        state = .paused
    }

    func resume() {
        guard state == .paused else { return }
        startDate = Date()
        state = .running

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func reset() {
        timer?.cancel()
        startDate = nil
        accumulatedSeconds = 0
        state = .idle
        displaySeconds = mode == .countdown ? countdownDuration : 0
    }

    func setCountdown(minutes: Int, seconds: Int) {
        countdownDuration = minutes * 60 + seconds
        if state == .idle {
            displaySeconds = countdownDuration
        }
    }

    func switchMode(to newMode: TimerMode) {
        reset()
        mode = newMode
        displaySeconds = newMode == .countdown ? countdownDuration : 0
    }

    // MARK: - Private

    private func tick() {
        let raw = currentRawSeconds()

        if mode == .stopwatch {
            displaySeconds = raw
        } else {
            let remaining = countdownDuration - raw
            if remaining <= 0 {
                displaySeconds = 0
                finish()
            } else {
                displaySeconds = remaining
            }
        }
    }

    private func finish() {
        timer?.cancel()
        state = .finished
    }

    private func currentRawSeconds() -> Int {
        let sinceStart = startDate.map { Int(Date().timeIntervalSince($0)) } ?? 0
        return accumulatedSeconds + sinceStart
    }

    // format seconds as MM:SS
    func formattedTime() -> String {
        let total = displaySeconds
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }

    // progress 0.0 to 1.0 for the ring (only meaningful in countdown mode)
    func progress() -> Double {
        guard mode == .countdown, countdownDuration > 0 else { return 0 }
        return Double(countdownDuration - displaySeconds) / Double(countdownDuration)
    }
}
