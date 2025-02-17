import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices {
  final GetStorage box = GetStorage();
  final key = 'isDarkMode';

  saveThemeToBox(bool isDarkMood) {
    return box.write(key, isDarkMood);
  }

  bool loadThemeFromBox() {
    return box.read(key) ?? false;
  }

  ThemeMode get theme {
    return loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;
  }

  void switchTheme() {
    Get.changeThemeMode(loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    saveThemeToBox(!loadThemeFromBox());
    }
}