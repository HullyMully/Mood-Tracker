class NotificationSettings {
  final bool enabled;
  final List<DateTime> reminders;
  final String notificationStyle;

  NotificationSettings({
    required this.enabled,
    required this.reminders,
    required this.notificationStyle,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'reminders': reminders.map((time) => time.toIso8601String()).toList(),
      'notificationStyle': notificationStyle,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'],
      reminders: (json['reminders'] as List)
          .map((time) => DateTime.parse(time))
          .toList(),
      notificationStyle: json['notificationStyle'],
    );
  }

  factory NotificationSettings.defaultSettings() {
    return NotificationSettings(
      enabled: true,
      reminders: [
        DateTime(2024, 1, 1, 9, 0),
        DateTime(2024, 1, 1, 14, 0),
        DateTime(2024, 1, 1, 20, 0),
      ],
      notificationStyle: 'emoji',
    );
  }
} 