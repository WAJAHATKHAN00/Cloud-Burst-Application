import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _loggedIn = false;
  bool _locationGranted = false;
  String _selectedCity = 'Islamabad, Pakistan';

  bool get loggedIn => _loggedIn;
  bool get locationGranted => _locationGranted;
  String get selectedCity => _selectedCity;

  void login() {
    _loggedIn = true;
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    _locationGranted = false;
    _selectedCity = 'Islamabad, Pakistan';
    notifyListeners();
  }

  void setLocationGranted(bool value) {
    _locationGranted = value;
    notifyListeners();
  }

  void setSelectedCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope?.notifier != null, 'AppStateScope not found in widget tree.');
    return scope!.notifier!;
  }
}
