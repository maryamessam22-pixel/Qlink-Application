import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/utils/emergency_profile_parse.dart';
import 'package:q_link/features/guardian/profile/public_preview_qr_page.dart';
import 'package:q_link/services/supabase_service.dart';

/// Builds [ProfileData] from a `patient_profiles` row map (Supabase or RPC `profile` json).
ProfileData profileDataFromPatientProfileRow(Map<String, dynamic> row) {
  final emergencyContacts = row['emergency_contacts'];
  final dialRows = emergencyDialRowsFromContactsJson(emergencyContacts);

  final contacts = <String>[];
  for (final r in dialRows) {
    if (r.phone.isNotEmpty) {
      contacts.add(r.title.isNotEmpty ? '${r.title}\n${r.phone}' : r.phone);
    } else if (r.title.isNotEmpty) {
      contacts.add(r.title);
    }
  }
  if (contacts.isEmpty && emergencyContacts is Map) {
    final rawMap = Map<dynamic, dynamic>.from(emergencyContacts);
    for (final entry in rawMap.entries) {
      final value = entry.value;
      if (value is Map && value['name'] != null) {
        contacts.add(value['name'].toString());
      } else if (value is String && value.trim().isNotEmpty) {
        contacts.add(value);
      }
    }
  } else if (contacts.isEmpty && emergencyContacts is String && emergencyContacts.trim().isNotEmpty) {
    try {
      final decoded = json.decode(emergencyContacts);
      if (decoded is Map) {
        return profileDataFromPatientProfileRow({...row, 'emergency_contacts': decoded});
      }
    } catch (_) {}
  }

  final med = (row['medical_notes_en'] ?? '').toString().trim();
  final safety = (row['safety_notes_en'] ?? '').toString().trim();
  final condition = med.isNotEmpty ? med : safety;

  return ProfileData(
    id: row['id']?.toString(),
    name: row['profile_name']?.toString() ?? 'Unknown',
    imagePath: row['avatar_url']?.toString() ?? '',
    relationship: row['relationship_to_guardian']?.toString() ?? '',
    birthYear: birthYearStringFromRowField(row['birth_year']),
    emergencyContacts: contacts,
    emergencyDialRows: dialRows,
    bloodType: row['blood_type']?.toString() ?? '',
    condition: condition,
    allergies: row['allergies_en']?.toString() ?? '',
  );
}

/// Parses `qlink://profile/{uuid}` or a bare UUID (legacy QR).
/// Turns camera-friendly `https://.../public-emergency?t=<token>` into RPC payload `qlink://qr/<token>`.
String normalizeQrPayloadForRpc(String raw) {
  final t = raw.trim();
  Uri u;
  try {
    u = Uri.parse(t);
  } catch (_) {
    return t;
  }
  if (u.scheme == 'https' && u.pathSegments.contains('public-emergency')) {
    final tok = u.queryParameters['t'];
    if (tok != null && tok.isNotEmpty) {
      return '${SupabaseService.qrPayloadPrefix}$tok';
    }
  }
  return t;
}

/// Parses `qlink://profile/{uuid}` or a bare UUID (legacy QR).
String? parseProfileUuidFromQrPayload(String raw) {
  final normalized = raw.trim();
  const prefix = 'qlink://profile/';
  if (normalized.startsWith(prefix)) {
    final id = normalized.substring(prefix.length).trim();
    return id.isEmpty ? null : id;
  }
  final uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
  return uuidRegex.hasMatch(normalized) ? normalized : null;
}

/// Preferred path: RPC records scan + notification, returns profile json.
/// Fallback: SELECT by UUID when RPC not deployed yet.
Future<void> navigateEmergencyPreviewFromQrRaw(
  BuildContext context,
  String raw,
) async {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return;

  final service = SupabaseService();
  final forRpc = normalizeQrPayloadForRpc(trimmed);

  final rpc = await service.recordQrScanAndFetchEmergency(forRpc);
  if (rpc != null &&
      rpc['ok'] == true &&
      rpc['profile'] != null &&
      rpc['profile'] is Map) {
    final preview =
        profileDataFromPatientProfileRow(Map<String, dynamic>.from(rpc['profile'] as Map));
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicPreviewQrPage(profile: preview, skipGuardianNotify: true),
      ),
    );
    return;
  }

  final uuid = parseProfileUuidFromQrPayload(trimmed);
  if (uuid == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unrecognized QR format.')),
      );
    }
    return;
  }

  final row = await service.fetchPatientProfileById(uuid);
  if (!context.mounted) return;
  if (row == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile not found for this QR code.')),
    );
    return;
  }

  final previewProfile = profileDataFromPatientProfileRow(row);
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PublicPreviewQrPage(profile: previewProfile),
    ),
  );
}
