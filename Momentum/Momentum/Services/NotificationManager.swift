//
//  NotificationManager.swift
//  Momentum
//
//  Created by Mutaz on 3/5/2026.
//

import Foundation
import UserNotifications

// this class handles all the notifications for our app
class NotificationManager {
    
    static let shared = NotificationManager()
    
    // ask the user if its ok to send notifications
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("user allowed notifications")
            } else {
                print("user denied notifications")
            }
        }
    }
    
    // schedule a daily notification for a habit at the reminder time the user set
    func scheduleNotification(for habit: Habit) {
        
        // cancel old notification first so we dont get duplicates
        cancelNotification(for: habit)
        
        //set up what the notification
        let content = UNMutableNotificationContent()
        content.title = "Time for: \(habit.name)"
        content.body = "Your goal is \(habit.goal) \(habit.unit.rawValue) today!"
        content.sound = .default
        
        // get the hour and minute from the reminder time the user picked
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: habit.reminderTime)
        let minute = calendar.component(.minute, from: habit.reminderTime)
        
        // set the time we want the notification to fire
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: habit.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        // add the notification to the queue
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("something went wrong: \(error.localizedDescription)")
            } else {
                print("notification set for \(habit.name) at \(hour):\(minute)")
            }
        }
    }
    
    // cancel the notification for a specific habit
    func cancelNotification(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [habit.id.uuidString]
        )
    }
    
    // cancel all notifications - useful if user clears all habits
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
