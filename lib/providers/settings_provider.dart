import 'package:flutter/material.dart';
import 'package:chatbotapp/hive/boxes.dart';
import 'package:chatbotapp/hive/settings.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _shouldSpeak = false;

  bool get isDarkMode => _isDarkMode;
  bool get shouldSpeak => _shouldSpeak;

  // Get the saved settings from box
  Future<void> getSavedSettings() async {
    final settingsBox = await Boxes.getSettings(); // ✅ await ekledik

    if (settingsBox.isNotEmpty) { // ✅ Hata giderildi
      final settings = settingsBox.getAt(0);
      if (settings != null) {
        _isDarkMode = settings.isDarkTheme;
        _shouldSpeak = settings.shouldSpeak;
        notifyListeners();
      }
    }
  }

  // Toggle dark mode
  Future<void> toggleDarkMode({required bool value, Settings? settings}) async {
    if (settings != null) {
      settings.isDarkTheme = value;
      await settings.save();
    } else {
      final settingsBox = await Boxes.getSettings(); // ✅ await ekledik
      await settingsBox.put(0, Settings(isDarkTheme: value, shouldSpeak: shouldSpeak));
    }

    _isDarkMode = value;
    notifyListeners();
  }

  // Toggle the speak
  Future<void> toggleSpeak({required bool value, Settings? settings}) async {
    if (settings != null) {
      settings.shouldSpeak = value;
      await settings.save();
    } else {
      final settingsBox = await Boxes.getSettings(); // ✅ await ekledik
      await settingsBox.put(0, Settings(isDarkTheme: isDarkMode, shouldSpeak: value));
    }

    _shouldSpeak = value;
    notifyListeners();
  }
}
