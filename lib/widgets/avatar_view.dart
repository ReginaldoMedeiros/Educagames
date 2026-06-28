import 'package:flutter/material.dart';

import '../models/child_profile.dart';
import '../theme/app_colors.dart';

/// Avatares base aprovados (12 meninos + 12 meninas). Cada um aponta para o
/// PNG real fatiado da folha de sprites aprovada.
class AvatarBase {
  const AvatarBase({required this.id, required this.asset, required this.color});
  final String id;
  final String asset;
  final Color color;
}

final List<AvatarBase> kAvatarBases = <AvatarBase>[
  for (int i = 1; i <= 12; i++)
    AvatarBase(
      id: 'avatar_boy_${i.toString().padLeft(3, '0')}',
      asset: 'assets/avatars/base/boys/boy_${i.toString().padLeft(2, '0')}.png',
      color: _palette[(i - 1) % _palette.length],
    ),
  for (int i = 1; i <= 12; i++)
    AvatarBase(
      id: 'avatar_girl_${i.toString().padLeft(3, '0')}',
      asset:
          'assets/avatars/base/girls/girl_${i.toString().padLeft(2, '0')}.png',
      color: _palette[(i + 5) % _palette.length],
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

/// Renderização do avatar: imagem base real dentro de uma plataforma circular,
/// com os cosméticos equipados (chapéu/óculos) sobrepostos em camadas.
/// A arquitetura de dados já prevê camadas (ver [ChildProfile.equipped]).
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

    // Os avatares aprovados são personagens completos — exibidos inteiros,
    // sem sobreposição de cosméticos (que não foram desenhados como camadas).
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: <Color>[
            Color.lerp(base.color, Colors.white, 0.7)!,
            Color.lerp(base.color, Colors.white, 0.3)!,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.only(top: size * 0.08),
          child: Image.asset(
            base.asset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.face_rounded,
                size: size * 0.6, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
