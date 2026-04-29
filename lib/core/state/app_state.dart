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

/// One row in the public emergency preview (name + optional dialable phone).
class EmergencyDialRow {
  final String title;
  final String phone;

  const EmergencyDialRow({required this.title, required this.phone});

  bool get canDial => phone.trim().isNotEmpty;
}

class ProfileData {
  String? id;
  String name;
  String imagePath;
  String relationship;
  String birthYear;
  List<String> emergencyContacts;
  /// Parsed from `emergency_contacts` JSON (name/phone). When non-empty, preview uses this for call buttons.
  final List<EmergencyDialRow> emergencyDialRows;
  String bloodType;
  String condition;
  String allergies;
  VisibilitySettings visibility;
  final List<DeviceData> devices;

  ProfileData({
    this.id,
    required this.name,
    required this.imagePath,
    required this.relationship,
    this.birthYear = '',
    this.emergencyContacts = const [],
    this.emergencyDialRows = const [],
    this.bloodType = '',
    this.condition = '',
    this.allergies = '',
    VisibilitySettings? visibility,
    List<DeviceData>? devices,
  }) : visibility = visibility ?? VisibilitySettings(),
       devices = devices ?? [];

  bool get hasDevice => devices.isNotEmpty;
}

class DeviceData {
  final String deviceType;
  final String code;
  final DateTime connectedAt;
  final int batteryLevel;
  final String signalStrength;
  final bool isConnected;

  DeviceData({
    required this.deviceType,
    required this.code,
    required this.connectedAt,
    this.batteryLevel = 100,
    this.signalStrength = 'Strong',
    this.isConnected = true,
  });
}

class UserProfile {
  String name;
  String email;
  String password;
  String imagePath;
  String role; // 'Guardian' or 'Wearer'

  UserProfile({
    required this.name,
    required this.email,
    required this.password,
    required this.imagePath,
    this.role = 'Guardian',
  });
}

class ScanHistoryItem {
  final String title;
  final String scanner;
  final String location;
  final String time;

  ScanHistoryItem({
    required this.title,
    required this.scanner,
    required this.location,
    required this.time,
  });
}

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Notification badge count
  int _unreadNotificationCount = 0;
  int get unreadNotificationCount => _unreadNotificationCount;

  void setUnreadNotificationCount(int count) {
    _unreadNotificationCount = count;
    notifyListeners();
  }

  void incrementUnreadNotifications() {
    _unreadNotificationCount++;
    notifyListeners();
  }

  void clearUnreadNotifications() {
    _unreadNotificationCount = 0;
    notifyListeners();
  }

  final List<ScanHistoryItem> _scanHistory = [
    ScanHistoryItem(
      title: "Emergency Scan (Karam's Bracelete)",
      scanner: '+20 123 456 7890',
      location: 'Cairo, Egypt',
      time: '2 hours ago',
    ),
  ];

  List<ScanHistoryItem> get scanHistory => _scanHistory;

  void addScanHistory(ScanHistoryItem item) {
    _scanHistory.insert(0, item);
    notifyListeners();
  }

  void clearScanHistory() {
    _scanHistory.clear();
    notifyListeners();
  }

  // Current logged in user profile
  UserProfile _currentUser = UserProfile(
    name: '',
    email: '',
    password: '',
    imagePath: '',
  );

  UserProfile get currentUser => _currentUser;

  void updateCurrentUser({
    String? name,
    String? email,
    String? password,
    String? imagePath,
    String? role,
  }) {
    if (name != null) _currentUser.name = name;
    if (email != null) _currentUser.email = email;
    if (password != null) _currentUser.password = password;
    if (imagePath != null) _currentUser.imagePath = imagePath;
    if (role != null) _currentUser.role = role;
    notifyListeners();
  }

  // --- Navigation State ---
  int _currentGuardianIndex = 0;
  int get currentGuardianIndex => _currentGuardianIndex;

  void setGuardianIndex(int index) {
    _currentGuardianIndex = index;
    notifyListeners();
  }

  int _currentWearerIndex = 0;
  int get currentWearerIndex => _currentWearerIndex;

  void setWearerIndex(int index) {
    _currentWearerIndex = index;
    notifyListeners();
  }
  // -------------------------

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

  bool _profilesDirty = false;
  bool get profilesDirty => _profilesDirty;

  void markProfilesDirty() {
    _profilesDirty = true;
    notifyListeners();
  }

  void clearProfilesDirty() {
    _profilesDirty = false;
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

  void clearData() {
    _currentUser = UserProfile(
      name: '',
      email: '',
      password: '',
      imagePath: '',
    );
    _profiles.clear();
    _scanHistory.clear();
    _profilesDirty = false;
    _currentGuardianIndex = 0;
    _currentWearerIndex = 0;
    notifyListeners();
  }
}
