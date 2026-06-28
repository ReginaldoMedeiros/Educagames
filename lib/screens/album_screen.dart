import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stickers.dart';
import '../models/child_profile.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

/// Álbum do Explorador: colecionáveis por categoria. Adesivos coletados
/// aparecem coloridos; os não coletados, como silhuetas.
class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});

  static const Map<String, String> _categoryLabels = <String, String>{
    'animals': 'Animais',
    'dinosaurs': 'Dinossauros',
    'space': 'Espaço',
    'ocean': 'Oceano',
    'library': 'Biblioteca',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        color: AppColors.kidsGreen,
        child: SafeArea(
          child: Consumer<AppState>(
            builder: (BuildContext context, AppState app, _) {
              final ChildProfile? p = app.activeProfile;
              if (p == null) return const SizedBox.shrink();
              final double pct = app.albumCompletion();
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: <Widget>[
                        const BackCircleButton(),
                        const SizedBox(width: 12),
                        const Text('Álbum do Explorador',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800)),
                        const Spacer(),
                        Text('${(pct * 100).round()}% completo',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: <Widget>[
                        for (final MapEntry<String, String> e
                            in _categoryLabels.entries)
                          _CategorySection(
                            title: e.value,
                            stickers: stickersByCategory(e.key),
                            collected: p.stickers,
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.stickers,
    required this.collected,
  });

  final String title;
  final List<StickerDef> stickers;
  final Set<String> collected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              for (final StickerDef s in stickers)
                _StickerSlot(
                    sticker: s, collected: collected.contains(s.id)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StickerSlot extends StatelessWidget {
  const _StickerSlot({required this.sticker, required this.collected});

  final StickerDef sticker;
  final bool collected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: collected
                ? AppColors.kidsGreen.withValues(alpha: 0.15)
                : Colors.black12,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: collected ? AppColors.kidsGreen : Colors.black26,
              width: 2,
            ),
          ),
          child: sticker.asset != null
              ? Padding(
                  padding: const EdgeInsets.all(6),
                  child: ColorFiltered(
                    // Coletado: cores reais. Não coletado: silhueta escura.
                    colorFilter: collected
                        ? const ColorFilter.mode(
                            Colors.transparent, BlendMode.dst)
                        : const ColorFilter.mode(
                            Colors.black45, BlendMode.srcATop),
                    child: Image.asset(sticker.asset!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(sticker.icon,
                            size: 40,
                            color: collected
                                ? AppColors.kidsGreen
                                : Colors.black26)),
                  ),
                )
              : Icon(
                  sticker.icon,
                  size: 40,
                  color: collected ? AppColors.kidsGreen : Colors.black26,
                ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          child: Text(
            collected ? sticker.name : '???',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
