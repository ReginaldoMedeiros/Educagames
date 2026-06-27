import 'package:flutter_test/flutter_test.dart';

import 'package:educa_games/data/cosmetics.dart';
import 'package:educa_games/data/game_content.dart';
import 'package:educa_games/data/rewards.dart';
import 'package:educa_games/models/child_profile.dart';
import 'package:educa_games/models/parental_settings.dart';
import 'package:educa_games/models/world.dart';

void main() {
  group('ParentalSettings.isWithinAllowedHours', () {
    test('janela padrão 08:00-20:00', () {
      final ParentalSettings s = ParentalSettings();
      expect(s.isWithinAllowedHours(8), isTrue);
      expect(s.isWithinAllowedHours(19), isTrue);
      expect(s.isWithinAllowedHours(20), isFalse);
      expect(s.isWithinAllowedHours(7), isFalse);
      expect(s.isWithinAllowedHours(0), isFalse);
    });

    test('janela que cruza a meia-noite', () {
      final ParentalSettings s =
          ParentalSettings(allowedStartHour: 20, allowedEndHour: 6);
      expect(s.isWithinAllowedHours(22), isTrue);
      expect(s.isWithinAllowedHours(3), isTrue);
      expect(s.isWithinAllowedHours(12), isFalse);
    });
  });

  group('RewardTable', () {
    test('valores por atividade seguem o documento mestre', () {
      expect(RewardTable.stars(GameId.coloring), 5);
      expect(RewardTable.stars(GameId.memory), 10);
      expect(RewardTable.stars(GameId.puzzle), 15);
      expect(RewardTable.stars(GameId.letters), 10);
      expect(RewardTable.coins(GameId.puzzle), 50);
    });
  });

  group('ChildProfile', () {
    test('nível e progresso derivados das estrelas', () {
      final ChildProfile p = ChildProfile(id: 'x', name: 'Teste', stars: 250);
      expect(p.level, 3); // 1 + 250 ~/ 100
      expect(p.levelProgress, closeTo(0.5, 0.001));
    });

    test('serialização ida e volta preserva o estado', () {
      final ChildProfile p = ChildProfile(
        id: 'abc',
        name: 'Lucas',
        age: 6,
        stars: 120,
        coins: 300,
        stickers: <String>{'animal_lion'},
        achievements: <String>{'first_adventure'},
        ownedCosmetics: <String>{'hat_safari'},
        equipped: <String, String>{'hat': 'hat_safari'},
      );
      final ChildProfile back = ChildProfile.fromJson(p.toJson());
      expect(back.name, 'Lucas');
      expect(back.stars, 120);
      expect(back.stickers.contains('animal_lion'), isTrue);
      expect(back.ownedCosmetics.contains('hat_safari'), isTrue);
      expect(back.equipped['hat'], 'hat_safari');
    });
  });

  group('Cosméticos e conteúdo', () {
    test('preços por raridade', () {
      expect(Rarity.common.price, 50);
      expect(Rarity.legendary.price, 800);
    });

    test('adesivo seguinte é determinístico e ignora os já coletados', () {
      final String? first =
          nextStickerForWorld(WorldId.animals, <String>{});
      expect(first, 'animal_elephant');
      final String? second =
          nextStickerForWorld(WorldId.animals, <String>{'animal_elephant'});
      expect(second, 'animal_lion');
    });
  });
}
