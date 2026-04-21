import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class AppState extends ChangeNotifier {
  bool _loggedIn = false;
  bool _locationGranted = false;
  String _selectedCity = 'Islamabad, Pakistan';

  // ✅ NEW: coordinates
  double _latitude = 33.6844;
  double _longitude = 73.0479;

  bool get loggedIn => _loggedIn;
  bool get locationGranted => _locationGranted;
  String get selectedCity => _selectedCity;

  // ✅ NEW getters
  double get latitude => _latitude;
  double get longitude => _longitude;

  void login() {
    _loggedIn = true;
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    _locationGranted = false;
    _selectedCity = 'Islamabad, Pakistan';
    _latitude = 33.6844;
    _longitude = 73.0479;
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

  // ✅ NEW: set coordinates
  void setLocation(double lat, double lon) {
    _latitude = lat;
    _longitude = lon;
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
