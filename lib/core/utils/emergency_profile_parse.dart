import 'dart:convert';

import 'package:q_link/core/state/app_state.dart';

bool looksLikePhoneField(String t) {
  final d = t.replaceAll(RegExp(r'[\s\-().]'), '');
  return RegExp(r'^\+?\d{7,15}$').hasMatch(d);
}

String _norm(String? s) => (s ?? '').trim();

/// Birth year as 4-digit string for [ProfileData.birthYear], or empty if invalid.
String birthYearStringFromRowField(dynamic v) {
  final y = parseBirthYearFromRowField(v);
  return y == null ? '' : '$y';
}

int? parseBirthYearFromRowField(dynamic v) {
  if (v == null) return null;
  final nowY = DateTime.now().year;
  if (v is int) {
    if (v >= 1900 && v <= nowY) return v;
    return null;
  }
  if (v is num) {
    final i = v.toInt();
    if (i >= 1900 && i <= nowY) return i;
    return null;
  }
  if (v is String) {
    final t = v.trim();
    if (t.isEmpty) return null;
    final dt = DateTime.tryParse(t);
    if (dt != null && dt.year >= 1900 && dt.year <= nowY) return dt.year;
    final i = int.tryParse(t);
    if (i != null && i >= 1900 && i <= nowY) return i;
    final parts = t.split(RegExp(r'[-/]'));
    if (parts.isNotEmpty) {
      final yi = int.tryParse(parts.first);
      if (yi != null && yi >= 1900 && yi <= nowY) return yi;
    }
  }
  return null;
}

int _contactKeyRank(String k) {
  if (k == 'primary') return 0;
  if (k == 'secondary') return 1;
  return 2;
}

List<String> _sortedEmergencyContactKeys(Map<dynamic, dynamic> map) {
  final keys = map.keys.map((e) => e.toString()).toList();
  keys.sort((a, b) {
    final ra = _contactKeyRank(a);
    final rb = _contactKeyRank(b);
    if (ra != rb) return ra.compareTo(rb);
    return a.compareTo(b);
  });
  return keys;
}

/// Rows for emergency preview + optional dial (from `emergency_contacts` JSON).
List<EmergencyDialRow> emergencyDialRowsFromContactsJson(dynamic emergencyContacts) {
  final rows = <EmergencyDialRow>[];
  if (emergencyContacts is String && emergencyContacts.trim().isNotEmpty) {
    try {
      final decoded = json.decode(emergencyContacts);
      return emergencyDialRowsFromContactsJson(decoded);
    } catch (_) {
      return rows;
    }
  }
  if (emergencyContacts is! Map) return rows;

  final map = Map<dynamic, dynamic>.from(emergencyContacts);
  for (final k in _sortedEmergencyContactKeys(map)) {
    final v = map[k];
    if (v is! Map) continue;
    final m = Map<String, dynamic>.from(v);
    var name = _norm(m['name']);
    final phoneRaw = _norm(m['phone']);
    final relation = _norm(m['relation']);

    if (phoneRaw.isNotEmpty) {
      final title = name.isNotEmpty
          ? name
          : (relation.isNotEmpty ? relation : (k == 'primary' ? 'Primary contact' : 'Contact'));
      rows.add(EmergencyDialRow(title: title, phone: phoneRaw));
    } else if (looksLikePhoneField(name)) {
      final title =
          relation.isNotEmpty ? relation : (k == 'primary' ? 'Primary contact' : 'Contact');
      rows.add(EmergencyDialRow(title: title, phone: name.replaceAll(RegExp(r'[\s\-()]'), '')));
    } else if (name.isNotEmpty) {
      rows.add(EmergencyDialRow(title: name, phone: ''));
    }
  }
  return rows;
}

/// Builds `emergency_contacts` JSON from flat text lines (name then optional phone on next line).
Map<String, dynamic> emergencyContactsJsonFromFlatLines(List<String> lines) {
  final merged = <Map<String, String>>[];
  for (final raw in lines) {
    final t = raw.trim();
    if (t.isEmpty) continue;
    if (merged.isNotEmpty &&
        (merged.last['phone'] ?? '').isEmpty &&
        looksLikePhoneField(t)) {
      merged.last['phone'] = t.replaceAll(RegExp(r'[^\d+]'), '');
    } else if (looksLikePhoneField(t)) {
      merged.add({'name': '', 'phone': t.replaceAll(RegExp(r'[^\d+]'), '')});
    } else {
      merged.add({'name': t, 'phone': ''});
    }
  }
  const keys = ['primary', 'secondary', 'contact_3', 'contact_4', 'contact_5', 'contact_6'];
  final out = <String, dynamic>{};
  for (var i = 0; i < merged.length && i < keys.length; i++) {
    var name = merged[i]['name'] ?? '';
    final phone = merged[i]['phone'] ?? '';
    if (name.isEmpty && phone.isNotEmpty) {
      name = i == 0 ? 'Primary contact' : 'Contact';
    }
    if (name.isEmpty && phone.isEmpty) continue;
    out[keys[i]] = {
      'name': name,
      'phone': phone,
      'relation': i == 0 ? 'Guardian' : 'Contact',
    };
  }
  return out;
}
