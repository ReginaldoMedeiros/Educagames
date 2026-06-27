import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/cosmetics.dart';
import '../models/child_profile.dart';
import '../theme/app_colors.dart';

/// Avatares base aprovados (12 meninos + 12 meninas no documento; aqui
/// representados por cor + ícone, já que não há assets externos no MVP).
class AvatarBase {
  const AvatarBase({required this.id, required this.color, required this.icon});
  final String id;
  final Color color;
  final IconData icon;
}

final List<AvatarBase> kAvatarBases = <AvatarBase>[
  for (int i = 1; i <= 12; i++)
    AvatarBase(
      id: 'avatar_boy_${i.toString().padLeft(3, '0')}',
      color: _palette[(i - 1) % _palette.length],
      icon: Icons.face_rounded,
    ),
  for (int i = 1; i <= 12; i++)
    AvatarBase(
      id: 'avatar_girl_${i.toString().padLeft(3, '0')}',
      color: _palette[(i + 5) % _palette.length],
      icon: Icons.face_3_rounded,
    ),
];

const List<Color> _palette = <Color>[
  AppColors.kidsBlue,
  AppColors.kidsGreen,
  AppColors.kidsOrange,
  AppColors.kidsPurple,
  AppColors.worldOcean,
  AppColors.worldDinosaurs,
];

AvatarBase avatarBaseById(String id) =>
    kAvatarBases.firstWhere((AvatarBase a) => a.id == id,
        orElse: () => kAvatarBases.first);

/// Renderização modular do avatar: base + camadas de cosméticos equipados.
/// No MVP usamos um preview simplificado (ícones sobrepostos), mas a
/// arquitetura de dados já prevê camadas (ver [ChildProfile.equipped]).
class AvatarView extends StatelessWidget {
  const AvatarView({
    super.key,
    required this.profile,
    this.size = 120,
  });

  final ChildProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final AvatarBase base = avatarBaseById(profile.avatarBaseId);
    // Ordem das camadas (de baixo para cima).
    const List<String> layerOrder = <String>[
      'clothes',
      'shoes',
      'backpack',
      'hat',
      'glasses',
      'accessory',
    ];
    final List<Cosmetic> equipped = <Cosmetic>[];
    for (final String cat in layerOrder) {
      final String? id = profile.equipped[cat];
      if (id != null) {
        final Cosmetic? c = cosmeticById(id);
        if (c != null) equipped.add(c);
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: base.color,
        shape: BoxShape.circle,
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(base.icon, size: size * 0.6, color: Colors.white),
          // Camadas de cosméticos (badges nas bordas para indicar equipados).
          ...equipped.asMap().entries.map((MapEntry<int, Cosmetic> e) {
            final double angle = (e.key / 6) * 2 * math.pi;
            return Align(
              alignment:
                  Alignment(0.85 * math.cos(angle), 0.85 * math.sin(angle)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: e.value.rarity.color, width: 2),
                ),
                child: Icon(e.value.icon,
                    size: size * 0.16, color: e.value.rarity.color),
              ),
            );
          }),
        ],
      ),
    );
  }
}
