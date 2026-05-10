# Momentum habit tracker

Momentum is a habit tracking iOS app built with SwiftUI that helps users build good habits, quit bad ones, and stay consistent every day.

---

## Features of the app

- Create and manage habits
- Daily reminder notifications
- Track progress and statistics
- Streak tracking system
- Weekly and monthly calendar view
- Timer based habits (minutes/hours)
- Goal based habit system
- Skip habits with tracking

---

## Screens

- Home (Today habits)
- Add Habit
- Habit Details
- Stats
- Timer Sheet

---

## Tech Stack

- SwiftUI
- UserDefaults (local storage)
- UserNotifications (reminders)
- JDStatusBarNotification (for success banners)

---

## Architecture

- **Models**: Habit data structure
- **Views**: UI screens
- **Services**: NotificationManager

---

## Notifications

The app schedules local notifications using:

```swift
UNUserNotificationCenter
