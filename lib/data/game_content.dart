import 'package:flutter/material.dart';

import '../models/world.dart';

/// Um "assunto" temático de um mundo, usado pelos minijogos (colorir, memória,
/// quebra-cabeça). Cada assunto pode conceder um adesivo específico do Álbum.
class Subject {
  const Subject({
    required this.name,
    required this.icon,
    required this.color,
    this.stickerId,
  });

  final String name;
  final IconData icon;
  final Color color;
  final String? stickerId;
}

/// Conteúdo temático por mundo. No MVP é gerado com ícones (sem assets
/// externos); a estrutura permite trocar por imagens reais depois.
const Map<WorldId, List<Subject>> kWorldSubjects = <WorldId, List<Subject>>{
  WorldId.animals: <Subject>[
    Subject(name: 'Elefante', icon: Icons.pets_rounded, color: Color(0xFF90A4AE), stickerId: 'animal_elephant'),
    Subject(name: 'Leão', icon: Icons.pets_rounded, color: Color(0xFFFFB300), stickerId: 'animal_lion'),
    Subject(name: 'Girafa', icon: Icons.pets_rounded, color: Color(0xFFFFCA28), stickerId: 'animal_giraffe'),
    Subject(name: 'Macaco', icon: Icons.pets_rounded, color: Color(0xFF8D6E63), stickerId: 'animal_monkey'),
    Subject(name: 'Coruja', icon: Icons.flutter_dash, color: Color(0xFF7E57C2), stickerId: 'animal_owl'),
    Subject(name: 'Borboleta', icon: Icons.emoji_nature_rounded, color: Color(0xFFEC407A)),
  ],
  WorldId.dinosaurs: <Subject>[
    Subject(name: 'T-Rex', icon: Icons.park_rounded, color: Color(0xFF66BB6A), stickerId: 'dino_trex'),
    Subject(name: 'Triceratops', icon: Icons.park_rounded, color: Color(0xFF26A69A), stickerId: 'dino_triceratops'),
    Subject(name: 'Braquiossauro', icon: Icons.park_rounded, color: Color(0xFF9CCC65), stickerId: 'dino_brachiosaurus'),
    Subject(name: 'Pterodáctilo', icon: Icons.flutter_dash, color: Color(0xFFFF7043), stickerId: 'dino_pterodactyl'),
    Subject(name: 'Vulcão', icon: Icons.terrain_rounded, color: Color(0xFFEF5350)),
    Subject(name: 'Fóssil', icon: Icons.egg_rounded, color: Color(0xFFA1887F)),
  ],
  WorldId.space: <Subject>[
    Subject(name: 'Planeta', icon: Icons.public_rounded, color: Color(0xFF42A5F5), stickerId: 'space_planet'),
    Subject(name: 'Astronauta', icon: Icons.person_rounded, color: Color(0xFFCFD8DC), stickerId: 'space_astronaut'),
    Subject(name: 'Foguete', icon: Icons.rocket_launch_rounded, color: Color(0xFFEF5350), stickerId: 'space_rocket'),
    Subject(name: 'Satélite', icon: Icons.satellite_alt_rounded, color: Color(0xFFB0BEC5), stickerId: 'space_satellite'),
    Subject(name: 'Estrela', icon: Icons.star_rounded, color: Color(0xFFFFEE58)),
    Subject(name: 'Lua', icon: Icons.nightlight_round, color: Color(0xFFE0E0E0)),
  ],
  WorldId.ocean: <Subject>[
    Subject(name: 'Peixe', icon: Icons.set_meal_rounded, color: Color(0xFFFF8A65), stickerId: 'ocean_fish'),
    Subject(name: 'Golfinho', icon: Icons.water_rounded, color: Color(0xFF4FC3F7), stickerId: 'ocean_dolphin'),
    Subject(name: 'Tartaruga', icon: Icons.water_rounded, color: Color(0xFF66BB6A), stickerId: 'ocean_turtle'),
    Subject(name: 'Polvo', icon: Icons.water_rounded, color: Color(0xFFBA68C8), stickerId: 'ocean_octopus'),
    Subject(name: 'Concha', icon: Icons.beach_access_rounded, color: Color(0xFFF06292)),
    Subject(name: 'Coral', icon: Icons.spa_rounded, color: Color(0xFFFF7043)),
  ],
  WorldId.library: <Subject>[
    Subject(name: 'Livro', icon: Icons.menu_book_rounded, color: Color(0xFF8D6E63), stickerId: 'library_book'),
    Subject(name: 'Globo', icon: Icons.public_rounded, color: Color(0xFF4DB6AC), stickerId: 'library_globe'),
    Subject(name: 'Lâmpada', icon: Icons.lightbulb_rounded, color: Color(0xFFFFD54F), stickerId: 'library_lamp'),
    Subject(name: 'Lápis', icon: Icons.edit_rounded, color: Color(0xFFFFB74D)),
    Subject(name: 'Mapa', icon: Icons.map_rounded, color: Color(0xFF81C784)),
    Subject(name: 'Bússola', icon: Icons.explore_rounded, color: Color(0xFF64B5F6)),
  ],
};

List<Subject> subjectsForWorld(WorldId id) =>
    kWorldSubjects[id] ?? const <Subject>[];

/// Primeiro adesivo ainda não coletado do mundo (entrega determinística, sem
/// aleatoriedade que lembre loot box). Retorna null se a coleção já estiver
/// completa para aquele mundo.
String? nextStickerForWorld(WorldId id, Set<String> collected) {
  for (final Subject s in subjectsForWorld(id)) {
    if (s.stickerId != null && !collected.contains(s.stickerId)) {
      return s.stickerId;
    }
  }
  return null;
}
