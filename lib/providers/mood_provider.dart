import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood.dart';
import '../models/notification_settings.dart';

class MoodProvider with ChangeNotifier {
  List<Mood> _moods = [];
  NotificationSettings _settings;
  final SharedPreferences _prefs;

  MoodProvider(this._prefs) : _settings = NotificationSettings.defaultSettings() {
    _loadMoods();
    _loadSettings();
  }

  List<Mood> get moods => List.unmodifiable(_moods);
  NotificationSettings get settings => _settings;

  void _loadMoods() {
    final String? moodsJson = _prefs.getString('moods');
    if (moodsJson != null) {
      final List<dynamic> decodedList = json.decode(moodsJson);
      _moods = decodedList.map((item) => Mood.fromJson(item)).toList();
      notifyListeners();
    }
  }

  void _loadSettings() {
    final String? settingsJson = _prefs.getString('settings');
    if (settingsJson != null) {
      _settings = NotificationSettings.fromJson(json.decode(settingsJson));
      notifyListeners();
    }
  }

  Future<void> addMood(Mood mood) async {
    _moods.insert(0, mood);
    await _saveMoods();
    notifyListeners();
  }

  Future<void> removeMood(int index) async {
    _moods.removeAt(index);
    await _saveMoods();
    notifyListeners();
  }

  Future<void> updateMood(int index, Mood mood) async {
    _moods[index] = mood;
    await _saveMoods();
    notifyListeners();
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    _settings = settings;
    await _saveSettings();
    notifyListeners();
  }

  List<Mood> getMoodsForPeriod(DateTime start, DateTime end) {
    return _moods.where((mood) =>
        mood.date.isAfter(start) &&
        mood.date.isBefore(end.add(const Duration(days: 1)))).toList();
  }

  Future<void> _saveMoods() async {
    final String encodedData = json.encode(
      _moods.map((mood) => mood.toJson()).toList(),
    );
    await _prefs.setString('moods', encodedData);
  }

  Future<void> _saveSettings() async {
    final String encodedData = json.encode(_settings.toJson());
    await _prefs.setString('settings', encodedData);
  }
} 