import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale("en");

  Locale get locale => _locale;

  LanguageProvider() {
    loadLanguage();
  }

  void loadLanguage() {
    var box = Hive.box("labours");

    String lang = box.get("language", defaultValue: "en");

    _locale = Locale(lang);

    notifyListeners();
  }

  Future<void> changeLanguage(String code) async {
    _locale = Locale(code);

    await Hive.box("labours").put("language", code);

    notifyListeners();
  }
}