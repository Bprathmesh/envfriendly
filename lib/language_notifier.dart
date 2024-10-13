import 'package:flutter/material.dart';

class LanguageNotifier with ChangeNotifier {
  Locale _locale = const Locale('en', '');

  Locale get locale => _locale;
  String get currentLanguage => _locale.languageCode;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void changeLanguage(String languageCode) {
    _locale = Locale(languageCode, '');
    notifyListeners();
  }
}