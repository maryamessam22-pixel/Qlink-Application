import 'package:flutter/material.dart';

class ProfileData {
  final String name;
  final String imagePath;
  final String bloodType;
  final String condition;
  final String allergies;

  ProfileData({
    required this.name,
    required this.imagePath,
    this.bloodType = '',
    this.condition = '',
    this.allergies = '',
  });
}

class DeviceData {
  final String deviceType;
  final String code;
  final DateTime connectedAt;

  DeviceData({
    required this.deviceType,
    required this.code,
    required this.connectedAt,
  });
}

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  final List<ProfileData> _profiles = [];
  final List<DeviceData> _devices = [];

  List<ProfileData> get profiles => List.unmodifiable(_profiles);
  List<DeviceData> get devices => List.unmodifiable(_devices);

  int get profileCount => _profiles.length;
  int get deviceCount => _devices.length;

  void addProfile(ProfileData profile) {
    _profiles.add(profile);
    notifyListeners();
  }

  void addDevice(DeviceData device) {
    _devices.add(device);
    notifyListeners();
  }

  void removeProfile(int index) {
    if (index >= 0 && index < _profiles.length) {
      _profiles.removeAt(index);
      notifyListeners();
    }
  }

  void removeDevice(int index) {
    if (index >= 0 && index < _devices.length) {
      _devices.removeAt(index);
      notifyListeners();
    }
  }
}
