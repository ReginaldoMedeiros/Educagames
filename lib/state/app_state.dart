import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../data/achievements.dart';
import '../data/cosmetics.dart';
import '../data/rewards.dart';
import '../data/stickers.dart';
import '../models/child_profile.dart';
import '../models/world.dart';
import '../services/storage_service.dart';

/// Fonte única de verdade do app. Mantém perfis, progresso, controle parental
/// e contagem de tempo. Persiste tudo via [StorageService] (local no MVP).
class AppState extends ChangeNotifier {
  AppState(this._storage) {
    _profiles = _storage.loadProfiles();
    final String? activeId = _storage.activeProfileId;
    if (activeId != null) {
      _activeProfileId =
          _profiles.any((ChildProfile p) => p.id == activeId) ? activeId : null;
    }
  }

  final StorageService _storage;

  List<ChildProfile> _profiles = <ChildProfile>[];
  String? _activeProfileId;
  Timer? _usageTimer;

  // --------------------------------------------------------------- getters
  List<ChildProfile> get profiles => List<ChildProfile>.unmodifiable(_profiles);
  bool get hasPin => _storage.hasPin;
  bool get premium => _storage.premium;

  /// Plano gratuito permite 1 perfil; Premium até 5.
  int get maxProfiles => premium ? 5 : 1;
  bool get canAddProfile => _profiles.length < maxProfiles;

  ChildProfile? get activeProfile {
    if (_activeProfileId == null) return null;
    for (final ChildProfile p in _profiles) {
      if (p.id == _activeProfileId) return p;
    }
    return null;
  }

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // ----------------------------------------------------------------- PIN
  bool verifyPin(String pin) => _storage.verifyPin(pin);

  Future<void> setPin(String pin) async {
    await _storage.setPin(pin);
    notifyListeners();
  }

  Future<void> setPremium(bool value) async {
    await _storage.setPremium(value);
    notifyListeners();
  }

  // ------------------------------------------------------------- profiles
  Future<ChildProfile> createProfile({
    required String name,
    int? age,
    String avatarBaseId = 'avatar_boy_001',
  }) async {
    final ChildProfile profile = ChildProfile(
      id: 'child_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      age: age,
      avatarBaseId: avatarBaseId,
    );
    _profiles.add(profile);
    await _storage.saveProfiles(_profiles);
    notifyListeners();
    return profile;
  }

  Future<void> deleteProfile(String id) async {
    _profiles.removeWhere((ChildProfile p) => p.id == id);
    if (_activeProfileId == id) {
      _activeProfileId = null;
      await _storage.setActiveProfile(null);
    }
    await _storage.saveProfiles(_profiles);
    notifyListeners();
  }

  Future<void> selectProfile(String id) async {
    _activeProfileId = id;
    await _storage.setActiveProfile(id);
    notifyListeners();
  }

  Future<void> clearActiveProfile() async {
    stopUsageTimer();
    _activeProfileId = null;
    await _storage.setActiveProfile(null);
    notifyListeners();
  }

  Future<void> _persistProfiles() => _storage.saveProfiles(_profiles);

  // ------------------------------------------------------- world unlocking
  bool isWorldUnlocked(World world) {
    final ChildProfile? p = activeProfile;
    if (p == null) return world.starsToUnlock == 0;
    return p.stars >= world.starsToUnlock;
  }

  // --------------------------------------------------------- time control
  int get dailyLimitMinutes =>
      activeProfile?.settings.dailyLimitMinutes ?? 60;

  int get usedMinutesToday {
    final ChildProfile? p = activeProfile;
    if (p == null) return 0;
    return _storage.usageMinutes(p.id, _todayKey);
  }

  int get extraMinutesToday {
    final ChildProfile? p = activeProfile;
    if (p == null) return 0;
    return _storage.extraMinutes(p.id, _todayKey);
  }

  int get remainingMinutes {
    final int total = dailyLimitMinutes + extraMinutesToday;
    return (total - usedMinutesToday).clamp(0, total);
  }

  bool get isWithinAllowedHours {
    final ChildProfile? p = activeProfile;
    if (p == null) return true;
    return p.settings.isWithinAllowedHours(DateTime.now().hour);
  }

  bool get isTimeUp => remainingMinutes <= 0;

  /// Regra-mestre: a criança só pode entrar nos jogos se houver tempo
  /// disponível E estiver dentro do horário permitido.
  bool get canPlayGames => !isTimeUp && isWithinAllowedHours;

  /// Inicia a contagem de tempo ativo (foreground) na área infantil.
  void startUsageTimer() {
    _usageTimer?.cancel();
    _usageTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _tickUsage();
    });
  }

  void stopUsageTimer() {
    _usageTimer?.cancel();
    _usageTimer = null;
  }

  Future<void> _tickUsage() async {
    final ChildProfile? p = activeProfile;
    if (p == null) return;
    final int current = _storage.usageMinutes(p.id, _todayKey);
    await _storage.setUsageMinutes(p.id, _todayKey, current + 1);
    notifyListeners();
  }

  /// Pais concedem tempo extra (exige PIN na UI). +15/+30/+60.
  /// Sem [profileId], aplica ao perfil ativo.
  Future<void> grantExtraTime(int minutes, {String? profileId}) async {
    final String? id = profileId ?? activeProfile?.id;
    if (id == null) return;
    final int current = _storage.extraMinutes(id, _todayKey);
    await _storage.setExtraMinutes(id, _todayKey, current + minutes);
    notifyListeners();
  }

  /// Minutos usados hoje por um perfil específico (relatório dos pais).
  int usageForProfileToday(String profileId) =>
      _storage.usageMinutes(profileId, _todayKey);

  /// Uso semanal (7 dias até hoje) para o relatório dos pais.
  List<int> weeklyUsage(String profileId) {
    final DateFormat fmt = DateFormat('yyyy-MM-dd');
    final DateTime now = DateTime.now();
    final List<String> keys = List<String>.generate(7, (int i) {
      return fmt.format(now.subtract(Duration(days: 6 - i)));
    });
    return _storage.weeklyUsage(profileId, keys);
  }

  // ----------------------------------------------------- parental settings
  Future<void> updateSettings(
    String profileId, {
    int? dailyLimitMinutes,
    int? allowedStartHour,
    int? allowedEndHour,
    bool? requirePinForSettings,
    bool? requirePinToExitKidsArea,
  }) async {
    final ChildProfile p =
        _profiles.firstWhere((ChildProfile e) => e.id == profileId);
    final s = p.settings;
    if (dailyLimitMinutes != null) s.dailyLimitMinutes = dailyLimitMinutes;
    if (allowedStartHour != null) s.allowedStartHour = allowedStartHour;
    if (allowedEndHour != null) s.allowedEndHour = allowedEndHour;
    if (requirePinForSettings != null) {
      s.requirePinForSettings = requirePinForSettings;
    }
    if (requirePinToExitKidsArea != null) {
      s.requirePinToExitKidsArea = requirePinToExitKidsArea;
    }
    await _persistProfiles();
    notifyListeners();
  }

  // ---------------------------------------------------------- gameplay
  /// Aplica o resultado de uma atividade concluída: estrelas, moedas,
  /// adesivo e novas conquistas. Retorna o [ActivityResult] enriquecido com
  /// as conquistas recém-desbloqueadas para a tela de recompensa.
  Future<ActivityResult> completeActivity({
    required WorldId world,
    required GameId game,
    bool perfect = false,
    String? stickerId,
  }) async {
    final ChildProfile? p = activeProfile;
    final int stars = RewardTable.stars(game);
    final int coins = RewardTable.coins(game) +
        (perfect ? RewardTable.perfectBonusCoins : 0);

    if (p == null) {
      return ActivityResult(
          world: world, game: game, stars: stars, coins: coins);
    }

    p.stars += stars;
    p.coins += coins;

    // Conta atividades concluídas no total (para conquistas de volume).
    _activityCount[p.id] = (_activityCount[p.id] ?? 0) + 1;
    _gameCount['${p.id}_${game.name}'] =
        (_gameCount['${p.id}_${game.name}'] ?? 0) + 1;

    if (stickerId != null) {
      p.stickers.add(stickerId);
    }

    final List<String> unlocked =
        _evaluateAchievements(p, world: world, game: game, perfect: perfect);

    await _persistProfiles();
    notifyListeners();

    return ActivityResult(
      world: world,
      game: game,
      stars: stars,
      coins: coins,
      stickerId: stickerId,
      perfect: perfect,
      newAchievements: unlocked,
    );
  }

  // Contadores em memória (sessão) usados para conquistas de volume.
  final Map<String, int> _activityCount = <String, int>{};
  final Map<String, int> _gameCount = <String, int>{};

  List<String> _evaluateAchievements(
    ChildProfile p, {
    required WorldId world,
    required GameId game,
    required bool perfect,
  }) {
    final List<String> newly = <String>[];

    void unlock(String id) {
      if (!p.achievements.contains(id) && achievementById(id) != null) {
        p.achievements.add(id);
        newly.add(id);
      }
    }

    unlock('first_adventure');

    final int colorCount = _gameCount['${p.id}_${GameId.coloring.name}'] ?? 0;
    final int puzzleCount = _gameCount['${p.id}_${GameId.puzzle.name}'] ?? 0;
    final int memoryCount = _gameCount['${p.id}_${GameId.memory.name}'] ?? 0;
    if (colorCount >= 3) unlock('color_master');
    if (puzzleCount >= 3) unlock('puzzle_explorer');
    if (memoryCount >= 3) unlock('memory_master');

    switch (world) {
      case WorldId.animals:
        unlock('animals_friend');
        break;
      case WorldId.dinosaurs:
        unlock('dino_explorer');
        break;
      case WorldId.space:
        unlock('space_traveler');
        break;
      case WorldId.ocean:
        unlock('ocean_friend');
        break;
      case WorldId.library:
        unlock('knowledge_keeper');
        break;
    }

    if (p.stickers.isNotEmpty) unlock('first_sticker');
    if (p.stickers.length >= 10) unlock('collector');
    if (p.equipped.isNotEmpty) unlock('stylish_avatar');
    if ((_activityCount[p.id] ?? 0) >= 10) unlock('persistent_explorer');
    if (game == GameId.letters && perfect) unlock('letters_no_error');
    if (p.stars >= 500) unlock('star_collector_500');

    return newly;
  }

  // ------------------------------------------------------------ cosmetics
  bool isOwned(String profileId, String cosmeticId) {
    final ChildProfile? p =
        _profiles.where((ChildProfile e) => e.id == profileId).isEmpty
            ? null
            : _profiles.firstWhere((ChildProfile e) => e.id == profileId);
    return p?.ownedCosmetics.contains(cosmeticId) ?? false;
  }

  /// Compra um cosmético com moedas. Retorna false se não houver moedas.
  Future<bool> buyCosmetic(Cosmetic c) async {
    final ChildProfile? p = activeProfile;
    if (p == null) return false;
    if (p.ownedCosmetics.contains(c.id)) return true;
    if (p.coins < c.price) return false;
    p.coins -= c.price;
    p.ownedCosmetics.add(c.id);
    await _persistProfiles();
    notifyListeners();
    return true;
  }

  Future<void> equipCosmetic(Cosmetic c) async {
    final ChildProfile? p = activeProfile;
    if (p == null) return;
    p.equipped[c.category] = c.id;
    p.ownedCosmetics.add(c.id);
    _evaluateAchievements(p, world: WorldId.library, game: GameId.coloring,
        perfect: false);
    await _persistProfiles();
    notifyListeners();
  }

  Future<void> unequipCategory(String category) async {
    final ChildProfile? p = activeProfile;
    if (p == null) return;
    p.equipped.remove(category);
    await _persistProfiles();
    notifyListeners();
  }

  // ------------------------------------------------------------ progress
  double albumCompletion() {
    final ChildProfile? p = activeProfile;
    if (p == null || kStickers.isEmpty) return 0;
    return p.stickers.length / kStickers.length;
  }

  @override
  void dispose() {
    _usageTimer?.cancel();
    super.dispose();
  }
}
