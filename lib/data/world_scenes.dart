import 'package:flutter/widgets.dart';

import '../models/world.dart';

/// Cenário de fundo de um mundo + posições (fracionárias 0..1) onde os botões
/// das atividades ficam, alinhados aos medalhões desenhados na arte.
class WorldScene {
  const WorldScene({required this.asset, this.slots = kDefaultSlots});

  /// Caminho do PNG do cenário (null = ainda sem arte, usa gradiente).
  final String? asset;

  /// Centros dos 3 medalhões (Colorir, Quebra-Cabeça, Memória), em fração da
  /// largura/altura da tela. Ajustáveis por mundo.
  final List<Offset> slots;
}

/// Layout padrão dos 3 medalhões (linha no terço inferior), válido para as
/// artes de cenário aprovadas (mesma composição em todos os mundos).
const List<Offset> kDefaultSlots = <Offset>[
  Offset(0.255, 0.76),
  Offset(0.50, 0.76),
  Offset(0.745, 0.76),
];

/// Mapa mundo -> cenário. Os mundos sem arte confirmada ficam com asset null
/// (caem no gradiente) até identificarmos os arquivos certos.
const Map<WorldId, WorldScene> kWorldScenes = <WorldId, WorldScene>{
  WorldId.ocean: WorldScene(asset: 'assets/worlds/ocean.png'),
  WorldId.dinosaurs: WorldScene(asset: 'assets/worlds/dinosaurs.png'),
  WorldId.library: WorldScene(asset: 'assets/worlds/library.png'),
  WorldId.animals: WorldScene(asset: null),
  WorldId.space: WorldScene(asset: null),
};

WorldScene sceneFor(WorldId id) =>
    kWorldScenes[id] ?? const WorldScene(asset: null);
