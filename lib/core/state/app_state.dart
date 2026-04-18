import 'package:flutter/material.dart';

class VisibilitySettings {
  bool showBloodType;
  bool showAllergies;
  bool showMedicalNotes;
  bool showEmergencyContacts;
  bool showBirthYear;
  bool showRelationship;

  VisibilitySettings({
    this.showBloodType = true,
    this.showAllergies = true,
    this.showMedicalNotes = true,
    this.showEmergencyContacts = true,
    this.showBirthYear = true,
    this.showRelationship = true,
  });
}

class ProfileData {
  String name;
  String imagePath;
  String relationship;
  String birthYear;
  List<String> emergencyContacts;
  String bloodType;
  String condition;
  String allergies;
  VisibilitySettings visibility;
  final List<DeviceData> devices;

  ProfileData({
    required this.name,
    required this.imagePath,
    required this.relationship,
    this.birthYear = '',
    this.emergencyContacts = const [],
    this.bloodType = '',
    this.condition = '',
    this.allergies = '',
    VisibilitySettings? visibility,
    List<DeviceData>? devices,
  })  : visibility = visibility ?? VisibilitySettings(),
        devices = devices ?? [];

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

  void updateProfile(int index, ProfileData profile) {
    if (index >= 0 && index < _profiles.length) {
      _profiles[index] = profile;
      notifyListeners();
    }
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

  bool _isArabic = false;
  bool get isArabic => _isArabic;

  void toggleLanguage() {
    _isArabic = !_isArabic;
    notifyListeners();
  }

  String tr(String en, String ar) {
    return _isArabic ? ar : en;
  }
}
