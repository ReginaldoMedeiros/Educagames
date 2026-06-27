import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/cosmetics.dart';
import '../models/child_profile.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_view.dart';
import '../widgets/common_widgets.dart';

/// Tela de Avatar: visualizar, comprar (moedas) e equipar cosméticos.
/// Cosméticos são apenas visuais e nunca dão vantagem no jogo.
class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  String _category = kCosmeticCategories.keys.first;

  Future<void> _onItemTap(
      BuildContext context, AppState app, ChildProfile p, Cosmetic c) async {
    final bool owned = app.isOwned(p.id, c.id);
    if (!owned) {
      if (p.coins < c.price) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Você precisa de ${c.price} moedas para ${c.name}. Continue jogando!')),
        );
        return;
      }
      final bool bought = await app.buyCosmetic(c);
      if (bought && context.mounted) {
        await app.equipCosmetic(c);
      }
    } else {
      // Alterna equipar/desequipar.
      if (p.equipped[c.category] == c.id) {
        await app.unequipCategory(c.category);
      } else {
        await app.equipCosmetic(c);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        color: AppColors.kidsPurple,
        child: SafeArea(
          child: Consumer<AppState>(
            builder: (BuildContext context, AppState app, _) {
              final ChildProfile? p = app.activeProfile;
              if (p == null) return const SizedBox.shrink();
              final List<Cosmetic> items = cosmeticsByCategory(_category);
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: <Widget>[
                        const BackCircleButton(),
                        const SizedBox(width: 12),
                        Text(p.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800)),
                        const Spacer(),
                        CurrencyChip(
                            icon: Icons.star_rounded,
                            value: p.stars,
                            color: AppColors.rewardGold),
                        const SizedBox(width: 8),
                        CurrencyChip(
                            icon: Icons.monetization_on_rounded,
                            value: p.coins,
                            color: AppColors.kidsOrange),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        // Categorias (lateral).
                        SizedBox(
                          width: 90,
                          child: ListView(
                            children: <Widget>[
                              for (final MapEntry<String, String> e
                                  in kCosmeticCategories.entries)
                                _CategoryButton(
                                  icon: kCosmeticCategoryIcons[e.key]!,
                                  label: e.value,
                                  selected: _category == e.key,
                                  onTap: () =>
                                      setState(() => _category = e.key),
                                ),
                            ],
                          ),
                        ),
                        // Avatar central na plataforma.
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              AvatarView(profile: p, size: 160),
                              const SizedBox(height: 8),
                              Container(
                                width: 160,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Carrossel de itens da categoria.
                  Container(
                    height: 130,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (BuildContext context, int i) {
                        final Cosmetic c = items[i];
                        final bool owned = app.isOwned(p.id, c.id);
                        final bool equipped = p.equipped[c.category] == c.id;
                        return _CosmeticCard(
                          cosmetic: c,
                          owned: owned,
                          equipped: equipped,
                          onTap: () => _onItemTap(context, app, p, c),
                        );
                      },
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

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(16),
            border: selected
                ? Border.all(color: AppColors.kidsPurple, width: 3)
                : null,
          ),
          child: Column(
            children: <Widget>[
              Icon(icon, color: AppColors.kidsPurple),
              const SizedBox(height: 2),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CosmeticCard extends StatelessWidget {
  const _CosmeticCard({
    required this.cosmetic,
    required this.owned,
    required this.equipped,
    required this.onTap,
  });

  final Cosmetic cosmetic;
  final bool owned;
  final bool equipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: equipped ? AppColors.kidsGreen : cosmetic.rarity.color,
            width: equipped ? 3 : 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(cosmetic.icon, size: 34, color: cosmetic.rarity.color),
            const SizedBox(height: 2),
            Text(cosmetic.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            if (equipped)
              const Text('Equipado',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.kidsGreen,
                      fontWeight: FontWeight.w700))
            else if (owned)
              const Text('Tocar p/ usar',
                  style: TextStyle(fontSize: 10, color: Colors.black54))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.monetization_on_rounded,
                      size: 14, color: AppColors.kidsOrange),
                  const SizedBox(width: 2),
                  Text('${cosmetic.price}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
