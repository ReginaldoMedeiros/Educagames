import 'package:flutter/material.dart';

/// Adesivo do Álbum do Explorador. Coletado ao completar atividades
/// relacionadas ao tema (sem aleatoriedade forte, sem cara de loot box).
class StickerDef {
  const StickerDef({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    this.asset,
  });

  final String id;
  final String name;
  final String category; // animals, dinosaurs, space, ocean, library
  final IconData icon;

  /// PNG real do adesivo (quando a arte estiver disponível); senão usa [icon].
  final String? asset;
}

/// Catálogo de adesivos por categoria/mundo.
const List<StickerDef> kStickers = <StickerDef>[
  // Animais
  StickerDef(id: 'animal_elephant', name: 'Elefante', category: 'animals', icon: Icons.pets_rounded),
  StickerDef(id: 'animal_lion', name: 'Leão', category: 'animals', icon: Icons.pets_rounded),
  StickerDef(id: 'animal_giraffe', name: 'Girafa', category: 'animals', icon: Icons.pets_rounded),
  StickerDef(id: 'animal_monkey', name: 'Macaco', category: 'animals', icon: Icons.pets_rounded),
  StickerDef(id: 'animal_owl', name: 'Coruja', category: 'animals', icon: Icons.flutter_dash),
  // Dinossauros
  StickerDef(id: 'dino_trex', name: 'T-Rex', category: 'dinosaurs', icon: Icons.park_rounded),
  StickerDef(id: 'dino_triceratops', name: 'Triceratops', category: 'dinosaurs', icon: Icons.park_rounded),
  StickerDef(id: 'dino_brachiosaurus', name: 'Braquiossauro', category: 'dinosaurs', icon: Icons.park_rounded),
  StickerDef(id: 'dino_pterodactyl', name: 'Pterodáctilo', category: 'dinosaurs', icon: Icons.park_rounded),
  // Espaço
  StickerDef(id: 'space_planet', name: 'Planeta', category: 'space', icon: Icons.public_rounded),
  StickerDef(id: 'space_astronaut', name: 'Astronauta', category: 'space', icon: Icons.person_rounded),
  StickerDef(id: 'space_rocket', name: 'Foguete', category: 'space', icon: Icons.rocket_launch_rounded),
  StickerDef(id: 'space_satellite', name: 'Satélite', category: 'space', icon: Icons.satellite_alt_rounded),
  // Oceano
  StickerDef(id: 'ocean_fish', name: 'Peixe', category: 'ocean', icon: Icons.water_rounded),
  StickerDef(id: 'ocean_dolphin', name: 'Golfinho', category: 'ocean', icon: Icons.water_rounded),
  StickerDef(id: 'ocean_turtle', name: 'Tartaruga', category: 'ocean', icon: Icons.water_rounded),
  StickerDef(id: 'ocean_octopus', name: 'Polvo', category: 'ocean', icon: Icons.water_rounded),
  // Biblioteca
  StickerDef(id: 'library_book', name: 'Livro', category: 'library', icon: Icons.menu_book_rounded),
  StickerDef(id: 'library_globe', name: 'Globo', category: 'library', icon: Icons.public_rounded),
  StickerDef(id: 'library_lamp', name: 'Lâmpada', category: 'library', icon: Icons.lightbulb_rounded),
];

List<StickerDef> stickersByCategory(String category) =>
    kStickers.where((StickerDef s) => s.category == category).toList();

StickerDef? stickerById(String id) {
  for (final StickerDef s in kStickers) {
    if (s.id == id) return s;
  }
  return null;
}
