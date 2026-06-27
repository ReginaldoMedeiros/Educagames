import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Identificadores dos mundos oficiais do Educa Games.
enum WorldId { library, animals, dinosaurs, space, ocean }

/// Identificadores dos minijogos do MVP.
enum GameId { coloring, puzzle, memory, letters }

extension GameLabel on GameId {
  String get label {
    switch (this) {
      case GameId.coloring:
        return 'Colorir';
      case GameId.puzzle:
        return 'Quebra-Cabeça';
      case GameId.memory:
        return 'Memória';
      case GameId.letters:
        return 'Letras e Números';
    }
  }

  IconData get icon {
    switch (this) {
      case GameId.coloring:
        return Icons.brush_rounded;
      case GameId.puzzle:
        return Icons.extension_rounded;
      case GameId.memory:
        return Icons.grid_view_rounded;
      case GameId.letters:
        return Icons.abc_rounded;
    }
  }
}

/// Definição estática de um mundo (não muda em runtime).
class World {
  const World({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.starsToUnlock,
    required this.stickerCategory,
  });

  final WorldId id;
  final String name;
  final IconData icon;
  final Color color;

  /// Estrelas necessárias para desbloquear (lógica preparada mesmo no MVP).
  final int starsToUnlock;

  /// Categoria de adesivos do Álbum do Explorador associada a este mundo.
  final String stickerCategory;
}

/// Catálogo oficial dos mundos. Ordem reflete a Biblioteca Central.
const List<World> kWorlds = <World>[
  World(
    id: WorldId.animals,
    name: 'Reino dos Animais',
    icon: Icons.pets_rounded,
    color: AppColors.worldAnimals,
    starsToUnlock: 0,
    stickerCategory: 'animals',
  ),
  World(
    id: WorldId.dinosaurs,
    name: 'Vale dos Dinossauros',
    icon: Icons.park_rounded,
    color: AppColors.worldDinosaurs,
    starsToUnlock: 100,
    stickerCategory: 'dinosaurs',
  ),
  World(
    id: WorldId.space,
    name: 'Estação Espacial',
    icon: Icons.rocket_launch_rounded,
    color: AppColors.worldSpace,
    starsToUnlock: 250,
    stickerCategory: 'space',
  ),
  World(
    id: WorldId.ocean,
    name: 'Reino do Oceano',
    icon: Icons.water_rounded,
    color: AppColors.worldOcean,
    starsToUnlock: 500,
    stickerCategory: 'ocean',
  ),
  World(
    id: WorldId.library,
    name: 'Mundo Biblioteca',
    icon: Icons.menu_book_rounded,
    color: AppColors.worldLibrary,
    starsToUnlock: 0,
    stickerCategory: 'library',
  ),
];

World worldById(WorldId id) => kWorlds.firstWhere((World w) => w.id == id);
