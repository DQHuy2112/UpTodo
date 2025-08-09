import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeChoice { system, light, dark }
enum DefaultSort { newest, priority }

class AppSettings {
  ThemeChoice theme;
  DefaultSort defaultSort;
  bool showCompleted;
  bool use24hTime;
  bool startWeekMonday;
  bool notificationsEnabled; // bạn có thể bỏ nếu không dùng
  TimeOfDay? dailyReminder;  // idem
  int accentColor;           // Color.value
  String languageCode;

  AppSettings({
    this.theme = ThemeChoice.system,
    this.defaultSort = DefaultSort.newest,
    this.showCompleted = true,
    this.use24hTime = false,
    this.startWeekMonday = true,
    this.notificationsEnabled = false,
    this.dailyReminder,
    this.accentColor = 0xFF8E7CFF,
    this.languageCode = 'vi',
  });

  // keys
  static const _kTheme = 's.theme';
  static const _kSort = 's.sort';
  static const _kCompleted = 's.showCompleted';
  static const _k24h = 's.use24h';
  static const _kMon = 's.monday';
  static const _kNoti = 's.noti';
  static const _kReminderH = 's.reminder.h';
  static const _kReminderM = 's.reminder.m';
  static const _kAccent = 's.accent';
  static const _kLang = 's.lang';

  static Future<AppSettings> load() async {
    final sp = await SharedPreferences.getInstance();
    final s = AppSettings();
    s.theme = ThemeChoice.values[sp.getInt(_kTheme) ?? s.theme.index];
    s.defaultSort = DefaultSort.values[sp.getInt(_kSort) ?? s.defaultSort.index];
    s.showCompleted = sp.getBool(_kCompleted) ?? s.showCompleted;
    s.use24hTime = sp.getBool(_k24h) ?? s.use24hTime;
    s.startWeekMonday = sp.getBool(_kMon) ?? s.startWeekMonday;
    s.notificationsEnabled = sp.getBool(_kNoti) ?? s.notificationsEnabled;
    final hh = sp.getInt(_kReminderH), mm = sp.getInt(_kReminderM);
    if (hh != null && mm != null) s.dailyReminder = TimeOfDay(hour: hh, minute: mm);
    s.accentColor = sp.getInt(_kAccent) ?? s.accentColor;
    s.languageCode = sp.getString(_kLang) ?? s.languageCode;
    return s;
  }

  static Future<void> save(AppSettings s) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kTheme, s.theme.index);
    await sp.setInt(_kSort, s.defaultSort.index);
    await sp.setBool(_kCompleted, s.showCompleted);
    await sp.setBool(_k24h, s.use24hTime);
    await sp.setBool(_kMon, s.startWeekMonday);
    await sp.setBool(_kNoti, s.notificationsEnabled);
    if (s.dailyReminder != null) {
      await sp.setInt(_kReminderH, s.dailyReminder!.hour);
      await sp.setInt(_kReminderM, s.dailyReminder!.minute);
    } else {
      await sp.remove(_kReminderH);
      await sp.remove(_kReminderM);
    }
    await sp.setInt(_kAccent, s.accentColor);
    await sp.setString(_kLang, s.languageCode);
  }
}
