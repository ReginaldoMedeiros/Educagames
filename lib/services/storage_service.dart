import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child_profile.dart';

/// Persistência local (MVP). A arquitetura está preparada para migrar para
/// Firestore/Firebase Auth depois — ver seção 31 do documento mestre.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _kPinHash = 'parent_pin_hash';
  static const String _kProfiles = 'child_profiles';
  static const String _kActiveProfile = 'active_profile_id';
  static const String _kPremium = 'premium';
  static const String _kUsagePrefix = 'usage_'; // usage_<profileId>_<yyyy-mm-dd>
  static const String _kExtraPrefix = 'extra_'; // extra_<profileId>_<yyyy-mm-dd>

  static Future<StorageService> create() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // ---- PIN dos pais ----
  String hashPin(String pin) =>
      sha256.convert(utf8.encode('educa_games::$pin')).toString();

  bool get hasPin => _prefs.containsKey(_kPinHash);

  Future<void> setPin(String pin) =>
      _prefs.setString(_kPinHash, hashPin(pin));

  bool verifyPin(String pin) => _prefs.getString(_kPinHash) == hashPin(pin);

  // ---- Assinatura (feature flag local no MVP) ----
  bool get premium => _prefs.getBool(_kPremium) ?? false;
  Future<void> setPremium(bool value) => _prefs.setBool(_kPremium, value);

  // ---- Perfis infantis ----
  List<ChildProfile> loadProfiles() {
    final String? raw = _prefs.getString(_kProfiles);
    if (raw == null) return <ChildProfile>[];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((dynamic e) =>
            ChildProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProfiles(List<ChildProfile> profiles) {
    final String raw = jsonEncode(
        profiles.map((ChildProfile p) => p.toJson()).toList());
    return _prefs.setString(_kProfiles, raw);
  }

  String? get activeProfileId => _prefs.getString(_kActiveProfile);

  Future<void> setActiveProfile(String? id) async {
    if (id == null) {
      await _prefs.remove(_kActiveProfile);
    } else {
      await _prefs.setString(_kActiveProfile, id);
    }
  }

  // ---- Tempo de uso diário ----
  int usageMinutes(String profileId, String dateKey) =>
      _prefs.getInt('$_kUsagePrefix${profileId}_$dateKey') ?? 0;

  Future<void> setUsageMinutes(
          String profileId, String dateKey, int minutes) =>
      _prefs.setInt('$_kUsagePrefix${profileId}_$dateKey', minutes);

  int extraMinutes(String profileId, String dateKey) =>
      _prefs.getInt('$_kExtraPrefix${profileId}_$dateKey') ?? 0;

  Future<void> setExtraMinutes(
          String profileId, String dateKey, int minutes) =>
      _prefs.setInt('$_kExtraPrefix${profileId}_$dateKey', minutes);

  /// Histórico semanal de uso para o relatório dos pais.
  List<int> weeklyUsage(String profileId, List<String> dateKeys) =>
      dateKeys.map((String k) => usageMinutes(profileId, k)).toList();
}
