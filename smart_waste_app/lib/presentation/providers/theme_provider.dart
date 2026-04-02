import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _settingsBox = 'settings';
  static const String _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    final box = Hive.box(_settingsBox);
    final String? mode = box.get(_themeKey);
    
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  void toggleTheme() {
    final box = Hive.box(_settingsBox);
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      box.put(_themeKey, 'light');
    } else {
      state = ThemeMode.dark;
      box.put(_themeKey, 'dark');
    }
  }

  static Future<void> init() async {
    await Hive.openBox(_settingsBox);
  }
}
