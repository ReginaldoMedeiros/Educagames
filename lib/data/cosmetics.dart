import 'package:flutter/material.dart';

/// Raridade dos cosméticos (apenas visual, nunca dá vantagem no jogo).
enum Rarity { common, uncommon, rare, epic, legendary }

extension RarityInfo on Rarity {
  String get label {
    switch (this) {
      case Rarity.common:
        return 'Comum';
      case Rarity.uncommon:
        return 'Incomum';
      case Rarity.rare:
        return 'Raro';
      case Rarity.epic:
        return 'Épico';
      case Rarity.legendary:
        return 'Lendário';
    }
  }

  /// Preço sugerido em moedas.
  int get price {
    switch (this) {
      case Rarity.common:
        return 50;
      case Rarity.uncommon:
        return 100;
      case Rarity.rare:
        return 200;
      case Rarity.epic:
        return 400;
      case Rarity.legendary:
        return 800;
    }
  }

  Color get color {
    switch (this) {
      case Rarity.common:
        return const Color(0xFF9E9E9E);
      case Rarity.uncommon:
        return const Color(0xFF43A047);
      case Rarity.rare:
        return const Color(0xFF1E88E5);
      case Rarity.epic:
        return const Color(0xFF8E24AA);
      case Rarity.legendary:
        return const Color(0xFFFFB300);
    }
  }
}

/// Categorias de cosméticos aprovadas.
const Map<String, String> kCosmeticCategories = <String, String>{
  'hat': 'Chapéus',
  'glasses': 'Óculos',
  'clothes': 'Roupas',
  'backpack': 'Mochilas',
  'shoes': 'Sapatos',
  'accessory': 'Acessórios',
};

const Map<String, IconData> kCosmeticCategoryIcons = <String, IconData>{
  'hat': Icons.emoji_people_rounded,
  'glasses': Icons.visibility_rounded,
  'clothes': Icons.checkroom_rounded,
  'backpack': Icons.backpack_rounded,
  'shoes': Icons.ice_skating_rounded,
  'accessory': Icons.auto_awesome_rounded,
};

/// Item cosmético comprável com moedas.
class Cosmetic {
  const Cosmetic({
    required this.id,
    required this.name,
    required this.category,
    required this.rarity,
    required this.icon,
    this.asset,
  });

  final String id;
  final String name;
  final String category;
  final Rarity rarity;
  final IconData icon;

  /// Caminho do PNG real (folha de sprites fatiada). Quando nulo, usa [icon].
  final String? asset;

  int get price => rarity.price;
}

/// Distribui raridades de forma estável pelo índice do item.
Rarity _rarityForIndex(int i) => Rarity.values[i % Rarity.values.length];

/// Gera itens cosméticos a partir das folhas de sprites reais já fatiadas.
List<Cosmetic> _fromSheet({
  required String category,
  required String namePrefix,
  required String dir,
  required String filePrefix,
  required int count,
  required IconData fallbackIcon,
}) {
  return <Cosmetic>[
    for (int i = 1; i <= count; i++)
      Cosmetic(
        id: '${category}_${i.toString().padLeft(2, '0')}',
        name: '$namePrefix $i',
        category: category,
        rarity: _rarityForIndex(i - 1),
        icon: fallbackIcon,
        asset: '$dir/${filePrefix}_${i.toString().padLeft(2, '0')}.png',
      ),
  ];
}

/// Catálogo cosmético. Chapéus e óculos usam a arte real aprovada; as demais
/// categorias seguem como ícones até as folhas serem fatiadas.
final List<Cosmetic> kCosmetics = <Cosmetic>[
  ..._fromSheet(
    category: 'hat',
    namePrefix: 'Chapéu',
    dir: 'assets/cosmetics/hats',
    filePrefix: 'hat',
    count: 36,
    fallbackIcon: Icons.emoji_people_rounded,
  ),
  ..._fromSheet(
    category: 'glasses',
    namePrefix: 'Óculos',
    dir: 'assets/cosmetics/glasses',
    filePrefix: 'glasses',
    count: 25,
    fallbackIcon: Icons.visibility_rounded,
  ),
  // Categorias ainda sem arte fatiada (placeholders por ícone).
  const Cosmetic(id: 'clothes_explorer', name: 'Roupa de Explorador', category: 'clothes', rarity: Rarity.uncommon, icon: Icons.checkroom_rounded),
  const Cosmetic(id: 'clothes_space', name: 'Traje Espacial', category: 'clothes', rarity: Rarity.epic, icon: Icons.rocket_launch_rounded),
  const Cosmetic(id: 'backpack_adventure', name: 'Mochila de Aventura', category: 'backpack', rarity: Rarity.common, icon: Icons.backpack_rounded),
  const Cosmetic(id: 'backpack_jet', name: 'Mochila a Jato', category: 'backpack', rarity: Rarity.legendary, icon: Icons.rocket_rounded),
  const Cosmetic(id: 'shoes_boots', name: 'Botas de Trilha', category: 'shoes', rarity: Rarity.common, icon: Icons.ice_skating_rounded),
  const Cosmetic(id: 'shoes_sneakers', name: 'Tênis Coloridos', category: 'shoes', rarity: Rarity.uncommon, icon: Icons.directions_run_rounded),
  const Cosmetic(id: 'accessory_compass', name: 'Bússola', category: 'accessory', rarity: Rarity.rare, icon: Icons.explore_rounded),
  const Cosmetic(id: 'accessory_lantern', name: 'Lanterna', category: 'accessory', rarity: Rarity.uncommon, icon: Icons.flashlight_on_rounded),
];

List<Cosmetic> cosmeticsByCategory(String category) =>
    kCosmetics.where((Cosmetic c) => c.category == category).toList();

Cosmetic? cosmeticById(String id) {
  for (final Cosmetic c in kCosmetics) {
    if (c.id == id) return c;
  }
  return null;
}
