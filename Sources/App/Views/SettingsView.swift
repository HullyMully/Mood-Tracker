import SwiftUI
import UserNotifications
import MoodTrackerCore

@available(macOS 13.0, *)
struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("morningReminder") private var morningReminder = true
    @AppStorage("afternoonReminder") private var afternoonReminder = true
    @AppStorage("eveningReminder") private var eveningReminder = true
    
    var body: some View {
        if #available(macOS 13.0, *) {
            Form {
                Section(header: Text("Уведомления")) {
                    Toggle("Включить уведомления", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { enabled in
                            if enabled {
                                requestNotificationPermission()
                            } else {
                                cancelAllNotifications()
                            }
                        }
                    
                    if notificationsEnabled {
                        Toggle("Утреннее напоминание (9:00)", isOn: $morningReminder)
                            .onChange(of: morningReminder) { enabled in
                                if enabled {
                                    scheduleNotification(at: 9, identifier: "morning")
                                } else {
                                    cancelNotification(identifier: "morning")
                                }
                            }
                        
                        Toggle("Дневное напоминание (14:00)", isOn: $afternoonReminder)
                            .onChange(of: afternoonReminder) { enabled in
                                if enabled {
                                    scheduleNotification(at: 14, identifier: "afternoon")
                                } else {
                                    cancelNotification(identifier: "afternoon")
                                }
                            }
                        
                        Toggle("Вечернее напоминание (20:00)", isOn: $eveningReminder)
                            .onChange(of: eveningReminder) { enabled in
                                if enabled {
                                    scheduleNotification(at: 20, identifier: "evening")
                                } else {
                                    cancelNotification(identifier: "evening")
                                }
                            }
                    }
                }
                
                Section(header: Text("О приложении")) {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Настройки")
        }
    }
    
    @available(macOS 13.0, *)
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                scheduleAllNotifications()
            }
        }
    }
    
    @available(macOS 13.0, *)
    private func scheduleAllNotifications() {
        if morningReminder {
            scheduleNotification(at: 9, identifier: "morning")
        }
        if afternoonReminder {
            scheduleNotification(at: 14, identifier: "afternoon")
        }
        if eveningReminder {
            scheduleNotification(at: 20, identifier: "evening")
        }
    }
    
    @available(macOS 13.0, *)
    private func scheduleNotification(at hour: Int, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "MoodTracker"
        content.body = "Как вы себя чувствуете сейчас?"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    @available(macOS 13.0, *)
    private func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    @available(macOS 13.0, *)
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
} 