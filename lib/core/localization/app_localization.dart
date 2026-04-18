import 'package:q_link/core/localization/app_strings.dart';
import 'package:q_link/core/state/app_state.dart';

/// Extension to make translation easier
extension AppLocalization on AppState {
  /// Get the translated string based on current language
  static String translate(String enString, String arString) {
    return AppState().isArabic ? arString : enString;
  }

  /// Get app strings based on language
  String tr(String enString, String arString) {
    return isArabic ? arString : enString;
  }

  /// Helper to get strings from AppStrings class
  String get appName => tr(AppStrings.appName, AppStringsAr.appName);
  String get qlink => tr(AppStrings.qlink, AppStringsAr.qlink);
  String get secureAccessRequired =>
      tr(AppStrings.secureAccessRequired, AppStringsAr.secureAccessRequired);
  String get emailPlaceholder =>
      tr(AppStrings.emailPlaceholder, AppStringsAr.emailPlaceholder);
  String get passwordPlaceholder =>
      tr(AppStrings.passwordPlaceholder, AppStringsAr.passwordPlaceholder);
  String get forgotPassword =>
      tr(AppStrings.forgotPassword, AppStringsAr.forgotPassword);
  String get signIn => tr(AppStrings.signIn, AppStringsAr.signIn);
  String get signInButton =>
      tr(AppStrings.signInButton, AppStringsAr.signInButton);
  String get or => tr(AppStrings.or, AppStringsAr.or);
  String get emergency => tr(AppStrings.emergency, AppStringsAr.emergency);
  String get publicEmergencyScan =>
      tr(AppStrings.publicEmergencyScan, AppStringsAr.publicEmergencyScan);
  String get newToQlink => tr(AppStrings.newToQlink, AppStringsAr.newToQlink);
  String get createAccount =>
      tr(AppStrings.createAccount, AppStringsAr.createAccount);
  String get createAccountPage =>
      tr(AppStrings.createAccountPage, AppStringsAr.createAccountPage);
  String get startsYourSafetyJourney => tr(
    AppStrings.startsYourSafetyJourney,
    AppStringsAr.startsYourSafetyJourney,
  );
  String get fullName => tr(AppStrings.fullName, AppStringsAr.fullName);
  String get emailAddress =>
      tr(AppStrings.emailAddress, AppStringsAr.emailAddress);
  String get password => tr(AppStrings.password, AppStringsAr.password);
  String get alreadyHaveAccount =>
      tr(AppStrings.alreadyHaveAccount, AppStringsAr.alreadyHaveAccount);

  String get home => tr(AppStrings.home, AppStringsAr.home);
  String get map => tr(AppStrings.map, AppStringsAr.map);
  String get vault => tr(AppStrings.vault, AppStringsAr.vault);
  String get settings => tr(AppStrings.settings, AppStringsAr.settings);
  String get actions => tr(AppStrings.actions, AppStringsAr.actions);
  String get settingsView =>
      tr(AppStrings.settingsView, AppStringsAr.settingsView);

  String get helloUser => tr(AppStrings.helloUser, AppStringsAr.helloUser);
  String get safetyCircleCommandCenter => tr(
    AppStrings.safetyCircleCommandCenter,
    AppStringsAr.safetyCircleCommandCenter,
  );
  String get online => tr(AppStrings.online, AppStringsAr.online);
  String get offline => tr(AppStrings.offline, AppStringsAr.offline);
  String get activeDevices =>
      tr(AppStrings.activeDevices, AppStringsAr.activeDevices);
  String get protectedMembers =>
      tr(AppStrings.protectedMembers, AppStringsAr.protectedMembers);
  String get systemStatus =>
      tr(AppStrings.systemStatus, AppStringsAr.systemStatus);
  String get systemFullyActive =>
      tr(AppStrings.systemFullyActive, AppStringsAr.systemFullyActive);
  String get deviceLinked =>
      tr(AppStrings.deviceLinked, AppStringsAr.deviceLinked);
  String get noDevicesConnected =>
      tr(AppStrings.noDevicesConnected, AppStringsAr.noDevicesConnected);
  String get protectedMember =>
      tr(AppStrings.protectedMember, AppStringsAr.protectedMember);
  String get addMember => tr(AppStrings.addMember, AppStringsAr.addMember);
  String get createProfile =>
      tr(AppStrings.createProfile, AppStringsAr.createProfile);
  String get createProfileDescription => tr(
    AppStrings.createProfileDescription,
    AppStringsAr.createProfileDescription,
  );
  String get addFirstProfile =>
      tr(AppStrings.addFirstProfile, AppStringsAr.addFirstProfile);
  String get connectBracelet =>
      tr(AppStrings.connectBracelet, AppStringsAr.connectBracelet);
  String get connectBraceletDescription => tr(
    AppStrings.connectBraceletDescription,
    AppStringsAr.connectBraceletDescription,
  );

  String get smartSafetyEcosystem =>
      tr(AppStrings.smartSafetyEcosystem, AppStringsAr.smartSafetyEcosystem);
  String get welcomeToQlink =>
      tr(AppStrings.welcomeToQlink, AppStringsAr.welcomeToQlink);
  String get chooseHowYouWantToUse =>
      tr(AppStrings.chooseHowYouWantToUse, AppStringsAr.chooseHowYouWantToUse);
  String get guardian => tr(AppStrings.guardian, AppStringsAr.guardian);
  String get guardianDescription =>
      tr(AppStrings.guardianDescription, AppStringsAr.guardianDescription);
  String get continueAsGuardian =>
      tr(AppStrings.continueAsGuardian, AppStringsAr.continueAsGuardian);
  String get wearer => tr(AppStrings.wearer, AppStringsAr.wearer);
  String get wearerDescription =>
      tr(AppStrings.wearerDescription, AppStringsAr.wearerDescription);
  String get continueAsWearer =>
      tr(AppStrings.continueAsWearer, AppStringsAr.continueAsWearer);

  String get searchRecordsOrProfiles => tr(
    AppStrings.searchRecordsOrProfiles,
    AppStringsAr.searchRecordsOrProfiles,
  );
  String get monitoredProfiles =>
      tr(AppStrings.monitoredProfiles, AppStringsAr.monitoredProfiles);
  String get activeMedicalProfilesLinked => tr(
    AppStrings.activeMedicalProfilesLinked,
    AppStringsAr.activeMedicalProfilesLinked,
  );
  String get viewAll => tr(AppStrings.viewAll, AppStringsAr.viewAll);
  String get monitoredUser =>
      tr(AppStrings.monitoredUser, AppStringsAr.monitoredUser);
  String get medicalReport =>
      tr(AppStrings.medicalReport, AppStringsAr.medicalReport);
  String get cardiology => tr(AppStrings.cardiology, AppStringsAr.cardiology);
  String get insuranceCard =>
      tr(AppStrings.insuranceCard, AppStringsAr.insuranceCard);
  String get latestPrescription =>
      tr(AppStrings.latestPrescription, AppStringsAr.latestPrescription);
  String get monitoredUserSince =>
      tr(AppStrings.monitoredUserSince, AppStringsAr.monitoredUserSince);

  String get medicalSummary =>
      tr(AppStrings.medicalSummary, AppStringsAr.medicalSummary);
  String get bloodType => tr(AppStrings.bloodType, AppStringsAr.bloodType);
  String get condition => tr(AppStrings.condition, AppStringsAr.condition);
  String get allergies => tr(AppStrings.allergies, AppStringsAr.allergies);
  String get emergencyContacts =>
      tr(AppStrings.emergencyContacts, AppStringsAr.emergencyContacts);
  String get vitalSnapshot =>
      tr(AppStrings.vitalSnapshot, AppStringsAr.vitalSnapshot);
  String get noAllergiesProvided =>
      tr(AppStrings.noAllergiesProvided, AppStringsAr.noAllergiesProvided);
  String get medicalNotes =>
      tr(AppStrings.medicalNotes, AppStringsAr.medicalNotes);
  String get noNotesProvided =>
      tr(AppStrings.noNotesProvided, AppStringsAr.noNotesProvided);

  String get generatePatientProfile => tr(
    AppStrings.generatePatientProfile,
    AppStringsAr.generatePatientProfile,
  );
  String get step1Of3Identity =>
      tr(AppStrings.step1Of3Identity, AppStringsAr.step1Of3Identity);
  String get patientFullName =>
      tr(AppStrings.patientFullName, AppStringsAr.patientFullName);
  String get nameExample =>
      tr(AppStrings.nameExample, AppStringsAr.nameExample);
  String get relationshipToYou =>
      tr(AppStrings.relationshipToYou, AppStringsAr.relationshipToYou);
  String get relationshipExample =>
      tr(AppStrings.relationshipExample, AppStringsAr.relationshipExample);
  String get birthYear => tr(AppStrings.birthYear, AppStringsAr.birthYear);
  String get birthYearExample =>
      tr(AppStrings.birthYearExample, AppStringsAr.birthYearExample);
  String get emergencyContactsHeader => tr(
    AppStrings.emergencyContactsHeader,
    AppStringsAr.emergencyContactsHeader,
  );
  String get addMoreContactNumber =>
      tr(AppStrings.addMoreContactNumber, AppStringsAr.addMoreContactNumber);
  String get continueToMedicalInfo =>
      tr(AppStrings.continueToMedicalInfo, AppStringsAr.continueToMedicalInfo);

  String get step2Of3Medical =>
      tr(AppStrings.step2Of3Medical, AppStringsAr.step2Of3Medical);
  String get back => tr(AppStrings.back, AppStringsAr.back);
  String get safetyNotes =>
      tr(AppStrings.safetyNotes, AppStringsAr.safetyNotes);

  String get step3Of3Hardware =>
      tr(AppStrings.step3Of3Hardware, AppStringsAr.step3Of3Hardware);
  String get connectDevice =>
      tr(AppStrings.connectDevice, AppStringsAr.connectDevice);
  String get findActivationCard =>
      tr(AppStrings.findActivationCard, AppStringsAr.findActivationCard);
  String get deviceType => tr(AppStrings.deviceType, AppStringsAr.deviceType);
  String get chooseDeviceType =>
      tr(AppStrings.chooseDeviceType, AppStringsAr.chooseDeviceType);
  String get qLinkSmartBraceletNova => tr(
    AppStrings.qLinkSmartBraceletNova,
    AppStringsAr.qLinkSmartBraceletNova,
  );
  String get qLinkSmartBraceletPulse => tr(
    AppStrings.qLinkSmartBraceletPulse,
    AppStringsAr.qLinkSmartBraceletPulse,
  );
  String get qLinkBandNonDigital =>
      tr(AppStrings.qLinkBandNonDigital, AppStringsAr.qLinkBandNonDigital);
  String get linkSmartWatch =>
      tr(AppStrings.linkSmartWatch, AppStringsAr.linkSmartWatch);

  String get qrCodeVisibility =>
      tr(AppStrings.qrCodeVisibility, AppStringsAr.qrCodeVisibility);
  String get chooseWhatInformationAppears => tr(
    AppStrings.chooseWhatInformationAppears,
    AppStringsAr.chooseWhatInformationAppears,
  );
  String get previewQrView =>
      tr(AppStrings.previewQrView, AppStringsAr.previewQrView);
  String get privacySettingsUpdated => tr(
    AppStrings.privacySettingsUpdated,
    AppStringsAr.privacySettingsUpdated,
  );

  String get device => tr(AppStrings.device, AppStringsAr.device);
  String get findMyBracelet =>
      tr(AppStrings.findMyBracelet, AppStringsAr.findMyBracelet);
  String get deleteBracelet =>
      tr(AppStrings.deleteBracelet, AppStringsAr.deleteBracelet);
  String get emergencyInfo =>
      tr(AppStrings.emergencyInfo, AppStringsAr.emergencyInfo);
  String get privacyControl =>
      tr(AppStrings.privacyControl, AppStringsAr.privacyControl);
  String get qrPreview => tr(AppStrings.qrPreview, AppStringsAr.qrPreview);

  String get braceletActive =>
      tr(AppStrings.braceletActive, AppStringsAr.braceletActive);
  String get searchSavedPlaces =>
      tr(AppStrings.searchSavedPlaces, AppStringsAr.searchSavedPlaces);

  String get closePreview =>
      tr(AppStrings.closePreview, AppStringsAr.closePreview);
  String get thisIsWhatRescuesSee =>
      tr(AppStrings.thisIsWhatRescuesSee, AppStringsAr.thisIsWhatRescuesSee);
  String get stayProtectedWithQlink => tr(
    AppStrings.stayProtectedWithQlink,
    AppStringsAr.stayProtectedWithQlink,
  );
  String get qlinkHelpsProtect =>
      tr(AppStrings.qlinkHelpsProtect, AppStringsAr.qlinkHelpsProtect);
  String get installTheApp =>
      tr(AppStrings.installTheApp, AppStringsAr.installTheApp);
  String get editProfile =>
      tr(AppStrings.editProfile, AppStringsAr.editProfile);
  String get cancel => tr(AppStrings.cancel, AppStringsAr.cancel);
  String get saveEdits => tr(AppStrings.saveEdits, AppStringsAr.saveEdits);
  String get delete => tr(AppStrings.delete, AppStringsAr.delete);
  String get profileUpdatedSuccessfully => tr(
    AppStrings.profileUpdatedSuccessfully,
    AppStringsAr.profileUpdatedSuccessfully,
  );

  String get privacyPolicy =>
      tr(AppStrings.privacyPolicy, AppStringsAr.privacyPolicy);
  String get termsOfService =>
      tr(AppStrings.termsOfService, AppStringsAr.termsOfService);
  String get support => tr(AppStrings.support, AppStringsAr.support);
  String get copyrightText =>
      tr(AppStrings.copyrightText, AppStringsAr.copyrightText);

  String get loading => tr(AppStrings.loading, AppStringsAr.loading);
  String get years => tr(AppStrings.years, AppStringsAr.years);
}
