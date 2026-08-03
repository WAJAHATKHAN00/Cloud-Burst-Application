import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class AppState extends ChangeNotifier {
  bool _loggedIn = false;
  bool _locationGranted = false;
  String _selectedCity = 'Islamabad, Pakistan';

  // ✅ Coordinates for currently active location
  double _latitude = 33.6844;
  double _longitude = 73.0479;

  // ✅ True physical device location
  double? _deviceLatitude;
  double? _deviceLongitude;
  String? _deviceCity;

  bool get loggedIn => _loggedIn;
  bool get locationGranted => _locationGranted;
  String get selectedCity => _selectedCity;

  // ✅ Active location getters
  double get latitude => _latitude;
  double get longitude => _longitude;

  // ✅ Device location getters
  double get deviceLatitude => _deviceLatitude ?? _latitude;
  double get deviceLongitude => _deviceLongitude ?? _longitude;
  String get deviceCity => _deviceCity ?? _selectedCity;

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
    _deviceLatitude = null;
    _deviceLongitude = null;
    _deviceCity = null;
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

  // ✅ Set active location coordinates
  void setLocation(double lat, double lon) {
    _latitude = lat;
    _longitude = lon;
    notifyListeners();
  }

  // ✅ Set physical device location
  void setDeviceLocation(double lat, double lon, [String? city]) {
    _deviceLatitude = lat;
    _deviceLongitude = lon;
    if (city != null && city.isNotEmpty) {
      _deviceCity = city;
    }
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
