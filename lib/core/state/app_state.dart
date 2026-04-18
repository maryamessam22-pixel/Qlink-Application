import 'package:flutter/material.dart';

class ProfileData {
  final String name;
  final String imagePath;
  final String relationship;
  final String bloodType;
  final String condition;
  final String allergies;
  final List<DeviceData> devices;

  ProfileData({
    required this.name,
    required this.imagePath,
    required this.relationship,
    this.bloodType = '',
    this.condition = '',
    this.allergies = '',
    List<DeviceData>? devices,
  }) : devices = devices ?? [];

  bool get hasDevice => devices.isNotEmpty;
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

  List<ProfileData> get profiles => List.unmodifiable(_profiles);

  int get profileCount => _profiles.length;
  int get deviceCount => _profiles.fold(0, (sum, p) => sum + p.devices.length);

  void addProfile(ProfileData profile) {
    _profiles.add(profile);
    notifyListeners();
  }

  void addDeviceToProfile(int profileIndex, DeviceData device) {
    if (profileIndex >= 0 && profileIndex < _profiles.length) {
      _profiles[profileIndex].devices.add(device);
      notifyListeners();
    }
  }

  void removeProfile(int index) {
    if (index >= 0 && index < _profiles.length) {
      _profiles.removeAt(index);
      notifyListeners();
    }
  }
}
