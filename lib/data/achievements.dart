import 'package:flutter/material.dart';

/// Definição de uma conquista. Meta MVP: ~30 conquistas (aqui 15 iniciais).
class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
}

/// Conquistas iniciais sugeridas no documento mestre.
const List<Achievement> kAchievements = <Achievement>[
  Achievement(
    id: 'first_adventure',
    name: 'Primeira Aventura',
    description: 'Complete sua primeira atividade.',
    icon: Icons.flag_rounded,
  ),
  Achievement(
    id: 'color_master',
    name: 'Mestre das Cores',
    description: 'Termine 3 desenhos de colorir.',
    icon: Icons.palette_rounded,
  ),
  Achievement(
    id: 'puzzle_explorer',
    name: 'Explorador de Quebra-Cabeça',
    description: 'Complete 3 quebra-cabeças.',
    icon: Icons.extension_rounded,
  ),
  Achievement(
    id: 'memory_master',
    name: 'Mestre da Memória',
    description: 'Vença 3 jogos da memória.',
    icon: Icons.grid_view_rounded,
  ),
  Achievement(
    id: 'animals_friend',
    name: 'Amigo dos Animais',
    description: 'Jogue no Reino dos Animais.',
    icon: Icons.pets_rounded,
  ),
  Achievement(
    id: 'dino_explorer',
    name: 'Explorador dos Dinossauros',
    description: 'Jogue no Vale dos Dinossauros.',
    icon: Icons.park_rounded,
  ),
  Achievement(
    id: 'space_traveler',
    name: 'Viajante Espacial',
    description: 'Jogue na Estação Espacial.',
    icon: Icons.rocket_launch_rounded,
  ),
  Achievement(
    id: 'ocean_friend',
    name: 'Amigo do Oceano',
    description: 'Jogue no Reino do Oceano.',
    icon: Icons.water_rounded,
  ),
  Achievement(
    id: 'knowledge_keeper',
    name: 'Guardião do Conhecimento',
    description: 'Jogue no Mundo Biblioteca.',
    icon: Icons.menu_book_rounded,
  ),
  Achievement(
    id: 'first_sticker',
    name: 'Primeiro Adesivo',
    description: 'Colete seu primeiro adesivo.',
    icon: Icons.emoji_emotions_rounded,
  ),
  Achievement(
    id: 'collector',
    name: 'Colecionador',
    description: 'Colete 10 adesivos.',
    icon: Icons.collections_bookmark_rounded,
  ),
  Achievement(
    id: 'stylish_avatar',
    name: 'Avatar Estiloso',
    description: 'Equipe seu primeiro item cosmético.',
    icon: Icons.checkroom_rounded,
  ),
  Achievement(
    id: 'persistent_explorer',
    name: 'Explorador Persistente',
    description: 'Complete 10 atividades no total.',
    icon: Icons.trending_up_rounded,
  ),
  Achievement(
    id: 'letters_no_error',
    name: 'Sem Erros',
    description: 'Acerte Letras e Números sem errar.',
    icon: Icons.verified_rounded,
  ),
  Achievement(
    id: 'star_collector_500',
    name: 'Caçador de Estrelas',
    description: 'Acumule 500 estrelas.',
    icon: Icons.star_rounded,
  ),
];

Achievement? achievementById(String id) {
  for (final Achievement a in kAchievements) {
    if (a.id == id) return a;
  }
  return null;
}
