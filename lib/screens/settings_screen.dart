import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../models/notification_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Text('Settings'),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildNotificationSection(context),
              const Divider(),
              _buildAppearanceSection(context),
              const Divider(),
              _buildAboutSection(context),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        final settings = provider.settings;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SwitchListTile(
              title: const Text('Enable Reminders'),
              value: settings.enabled,
              onChanged: (value) {
                provider.updateSettings(
                  NotificationSettings(
                    enabled: value,
                    reminders: settings.reminders,
                    notificationStyle: settings.notificationStyle,
                  ),
                );
              },
            ),
            if (settings.enabled) ...[
              ListTile(
                title: const Text('Reminder Times'),
                subtitle: Text(
                  settings.reminders
                      .map((time) =>
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}')
                      .join(', '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showReminderTimePicker(context, provider, settings),
              ),
              ListTile(
                title: const Text('Notification Style'),
                subtitle: Text(_formatNotificationStyle(settings.notificationStyle)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showNotificationStylePicker(context, provider, settings),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListTile(
          title: const Text('Theme'),
          subtitle: const Text('System'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Theme selection will be implemented later
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListTile(
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Privacy policy will be implemented later
          },
        ),
        ListTile(
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Terms of service will be implemented later
          },
        ),
      ],
    );
  }

  void _showReminderTimePicker(
    BuildContext context,
    MoodProvider provider,
    NotificationSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder Times'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: settings.reminders.length + 1,
            itemBuilder: (context, index) {
              if (index == settings.reminders.length) {
                return ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Reminder'),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      final newReminder = DateTime(
                        2024,
                        1,
                        1,
                        time.hour,
                        time.minute,
                      );
                      final newReminders = [...settings.reminders, newReminder]
                        ..sort();
                      provider.updateSettings(
                        NotificationSettings(
                          enabled: settings.enabled,
                          reminders: newReminders,
                          notificationStyle: settings.notificationStyle,
                        ),
                      );
                    }
                  },
                );
              }

              final reminder = settings.reminders[index];
              return ListTile(
                title: Text(
                  '${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    final newReminders = [...settings.reminders]..removeAt(index);
                    provider.updateSettings(
                      NotificationSettings(
                        enabled: settings.enabled,
                        reminders: newReminders,
                        notificationStyle: settings.notificationStyle,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showNotificationStylePicker(
    BuildContext context,
    MoodProvider provider,
    NotificationSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Notification Style'),
        children: [
          'emoji',
          'text',
          'quote',
        ].map((style) => SimpleDialogOption(
              onPressed: () {
                provider.updateSettings(
                  NotificationSettings(
                    enabled: settings.enabled,
                    reminders: settings.reminders,
                    notificationStyle: style,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text(_formatNotificationStyle(style)),
            )).toList(),
      ),
    );
  }

  String _formatNotificationStyle(String style) {
    switch (style) {
      case 'emoji':
        return 'Emoji Style';
      case 'text':
        return 'Text Only';
      case 'quote':
        return 'With Quotes';
      default:
        return style;
    }
  }
} 