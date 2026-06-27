import '../models/world.dart';

/// Valores de recompensa por atividade (seção 18 do documento mestre).
class RewardTable {
  RewardTable._();

  static int stars(GameId game) {
    switch (game) {
      case GameId.coloring:
        return 5;
      case GameId.memory:
        return 10;
      case GameId.puzzle:
        return 15;
      case GameId.letters:
        return 10;
    }
  }

  static int coins(GameId game) {
    switch (game) {
      case GameId.coloring:
        return 20;
      case GameId.memory:
        return 30;
      case GameId.puzzle:
        return 50;
      case GameId.letters:
        return 25;
    }
  }

  /// Bônus opcional de conclusão perfeita (sempre +5 moedas).
  static const int perfectBonusCoins = 5;
}

/// Resultado de uma atividade concluída, usado pela tela de recompensa.
class ActivityResult {
  ActivityResult({
    required this.world,
    required this.game,
    required this.stars,
    required this.coins,
    this.stickerId,
    this.perfect = false,
    this.newAchievements = const <String>[],
  });

  final WorldId world;
  final GameId game;
  final int stars;
  final int coins;
  final String? stickerId;
  final bool perfect;
  final List<String> newAchievements;
}
