import 'parental_settings.dart';

/// Perfil infantil. Mantém progresso educativo (estrelas), moedas cosméticas,
/// coleções (adesivos), conquistas e itens equipados.
///
/// Espelha a coleção `childProfiles` sugerida para o Firestore, mas aqui é
/// persistido localmente (SharedPreferences) no MVP.
class ChildProfile {
  ChildProfile({
    required this.id,
    required this.name,
    this.age,
    this.avatarBaseId = 'avatar_boy_001',
    this.stars = 0,
    this.coins = 0,
    Set<String>? stickers,
    Set<String>? achievements,
    Set<String>? ownedCosmetics,
    Map<String, String>? equipped,
    ParentalSettings? settings,
  })  : stickers = stickers ?? <String>{},
        achievements = achievements ?? <String>{},
        ownedCosmetics = ownedCosmetics ?? <String>{},
        equipped = equipped ?? <String, String>{},
        settings = settings ?? ParentalSettings();

  final String id;
  String name;
  int? age;
  String avatarBaseId;

  /// Progresso educativo. NUNCA pode ser comprado.
  int stars;

  /// Moedas apenas cosméticas.
  int coins;

  /// Adesivos coletados (Álbum do Explorador). Guarda os ids.
  final Set<String> stickers;

  /// Conquistas concluídas (ids).
  final Set<String> achievements;

  /// Cosméticos comprados (ids), independente de estarem equipados.
  final Set<String> ownedCosmetics;

  /// Itens cosméticos equipados, por categoria. Ex.: {'hat': 'hat_001'}.
  final Map<String, String> equipped;

  /// Configurações de controle parental específicas deste perfil.
  final ParentalSettings settings;

  /// Nível derivado das estrelas (1 nível a cada 100 estrelas, mínimo 1).
  int get level => 1 + stars ~/ 100;

  /// Progresso (0..1) rumo ao próximo nível.
  double get levelProgress => (stars % 100) / 100.0;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'age': age,
        'avatarBaseId': avatarBaseId,
        'stars': stars,
        'coins': coins,
        'stickers': stickers.toList(),
        'achievements': achievements.toList(),
        'ownedCosmetics': ownedCosmetics.toList(),
        'equipped': equipped,
        'settings': settings.toJson(),
      };

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int?,
      avatarBaseId: json['avatarBaseId'] as String? ?? 'avatar_boy_001',
      stars: json['stars'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      stickers: (json['stickers'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e as String)
          .toSet(),
      achievements: (json['achievements'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e as String)
          .toSet(),
      ownedCosmetics:
          (json['ownedCosmetics'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic e) => e as String)
              .toSet(),
      equipped: (json['equipped'] as Map<String, dynamic>? ?? <String, dynamic>{})
          .map((String k, dynamic v) => MapEntry<String, String>(k, v as String)),
      settings: json['settings'] == null
          ? ParentalSettings()
          : ParentalSettings.fromJson(
              json['settings'] as Map<String, dynamic>),
    );
  }
}
