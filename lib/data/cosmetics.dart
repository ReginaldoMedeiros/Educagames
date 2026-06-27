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
  });

  final String id;
  final String name;
  final String category;
  final Rarity rarity;
  final IconData icon;

  int get price => rarity.price;
}

/// Catálogo cosmético inicial (amostra do total previsto de ~150 itens).
const List<Cosmetic> kCosmetics = <Cosmetic>[
  // Chapéus
  Cosmetic(id: 'hat_safari', name: 'Chapéu Safari', category: 'hat', rarity: Rarity.common, icon: Icons.emoji_people_rounded),
  Cosmetic(id: 'hat_party', name: 'Chapéu de Festa', category: 'hat', rarity: Rarity.uncommon, icon: Icons.celebration_rounded),
  Cosmetic(id: 'hat_crown', name: 'Coroa', category: 'hat', rarity: Rarity.epic, icon: Icons.workspace_premium_rounded),
  // Óculos
  Cosmetic(id: 'glasses_round', name: 'Óculos Redondos', category: 'glasses', rarity: Rarity.common, icon: Icons.visibility_rounded),
  Cosmetic(id: 'glasses_sun', name: 'Óculos de Sol', category: 'glasses', rarity: Rarity.rare, icon: Icons.wb_sunny_rounded),
  // Roupas
  Cosmetic(id: 'clothes_explorer', name: 'Roupa de Explorador', category: 'clothes', rarity: Rarity.uncommon, icon: Icons.checkroom_rounded),
  Cosmetic(id: 'clothes_space', name: 'Traje Espacial', category: 'clothes', rarity: Rarity.epic, icon: Icons.rocket_launch_rounded),
  // Mochilas
  Cosmetic(id: 'backpack_adventure', name: 'Mochila de Aventura', category: 'backpack', rarity: Rarity.common, icon: Icons.backpack_rounded),
  Cosmetic(id: 'backpack_jet', name: 'Mochila a Jato', category: 'backpack', rarity: Rarity.legendary, icon: Icons.rocket_rounded),
  // Sapatos
  Cosmetic(id: 'shoes_boots', name: 'Botas de Trilha', category: 'shoes', rarity: Rarity.common, icon: Icons.ice_skating_rounded),
  Cosmetic(id: 'shoes_sneakers', name: 'Tênis Coloridos', category: 'shoes', rarity: Rarity.uncommon, icon: Icons.directions_run_rounded),
  // Acessórios
  Cosmetic(id: 'accessory_compass', name: 'Bússola', category: 'accessory', rarity: Rarity.rare, icon: Icons.explore_rounded),
  Cosmetic(id: 'accessory_lantern', name: 'Lanterna', category: 'accessory', rarity: Rarity.uncommon, icon: Icons.flashlight_on_rounded),
];

List<Cosmetic> cosmeticsByCategory(String category) =>
    kCosmetics.where((Cosmetic c) => c.category == category).toList();

Cosmetic? cosmeticById(String id) {
  for (final Cosmetic c in kCosmetics) {
    if (c.id == id) return c;
  }
  return null;
}
