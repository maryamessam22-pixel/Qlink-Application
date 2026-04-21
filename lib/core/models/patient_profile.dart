import 'dart:convert';

class PatientProfile {
  final String id;
  final String guardianId;
  final String profileName;
  final String relationshipToGuardian;
  final int birthYear;
  final int age;
  final Map<String, dynamic> emergencyContacts;
  final String bloodType;
  final String safetyNotesEn;
  final String allergiesEn;
  final String medicalNotesEn;
  final String medicalNotesAr;
  final bool status;
  final String avatarUrl;
  final String deviceCode;
  final String seoSlug;
  final String metaTitleEn;
  final String metaDescriptionEn;
  final String featuredImageAltEn;
  final String safetyNotesAr;
  final String allergiesAr;
  final String metaTitleAr;
  final String metaDescriptionAr;
  final String featuredImageAltAr;
  final DateTime createdAt;

  PatientProfile({
    required this.id,
    required this.guardianId,
    required this.profileName,
    required this.relationshipToGuardian,
    required this.birthYear,
    required this.age,
    required this.emergencyContacts,
    required this.bloodType,
    required this.safetyNotesEn,
    required this.allergiesEn,
    required this.medicalNotesEn,
    required this.medicalNotesAr,
    required this.status,
    required this.avatarUrl,
    required this.deviceCode,
    required this.seoSlug,
    required this.metaTitleEn,
    required this.metaDescriptionEn,
    required this.featuredImageAltEn,
    required this.safetyNotesAr,
    required this.allergiesAr,
    required this.metaTitleAr,
    required this.metaDescriptionAr,
    required this.featuredImageAltAr,
    required this.createdAt,
  });

  factory PatientProfile.fromMap(Map<String, dynamic> map) {
    return PatientProfile(
      id: map['id'] ?? '',
      guardianId: map['guardian_id'] ?? '',
      profileName: map['profile_name'] ?? '',
      relationshipToGuardian: map['relationship_to_guardian'] ?? '',
      birthYear: map['birth_year']?.toInt() ?? 0,
      age: map['age']?.toInt() ?? 0,
      emergencyContacts: map['emergency_contacts'] is String 
          ? json.decode(map['emergency_contacts']) 
          : map['emergency_contacts'] ?? {},
      bloodType: map['blood_type'] ?? '',
      safetyNotesEn: map['safety_notes_en'] ?? '',
      allergiesEn: map['allergies_en'] ?? '',
      medicalNotesEn: map['medical_notes_en'] ?? '',
      medicalNotesAr: map['medical_notes_ar'] ?? '',
      status: map['status'] ?? false,
      avatarUrl: map['avatar_url'] ?? '',
      deviceCode: map['device_code'] ?? '',
      seoSlug: map['seo_slug'] ?? '',
      metaTitleEn: map['meta_title_en'] ?? '',
      metaDescriptionEn: map['meta_description_en'] ?? '',
      featuredImageAltEn: map['featured_image_alt_en'] ?? '',
      safetyNotesAr: map['safety_notes_ar'] ?? '',
      allergiesAr: map['allergies_ar'] ?? '',
      metaTitleAr: map['meta_title_ar'] ?? '',
      metaDescriptionAr: map['meta_description_ar'] ?? '',
      featuredImageAltAr: map['featured_image_alt_ar'] ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guardian_id': guardianId,
      'profile_name': profileName,
      'relationship_to_guardian': relationshipToGuardian,
      'birth_year': birthYear,
      'age': age,
      'emergency_contacts': emergencyContacts,
      'blood_type': bloodType,
      'safety_notes_en': safetyNotesEn,
      'allergies_en': allergiesEn,
      'medical_notes_en': medicalNotesEn,
      'medical_notes_ar': medicalNotesAr,
      'status': status,
      'avatar_url': avatarUrl,
      'seo_slug': seoSlug,
      'meta_title_en': metaTitleEn,
      'meta_description_en': metaDescriptionEn,
      'featured_image_alt_en': featuredImageAltEn,
      'safety_notes_ar': safetyNotesAr,
      'allergies_ar': allergiesAr,
      'meta_title_ar': metaTitleAr,
      'meta_description_ar': metaDescriptionAr,
      'featured_image_alt_ar': featuredImageAltAr,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
