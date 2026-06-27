import 'package:flutter/material.dart';

/// Paleta visual oficial do Educa Games.
///
/// Duas linguagens visuais distintas:
///  - [kids]  -> área infantil: cores vibrantes, alegres, dourado nas recompensas.
///  - [parent]-> área dos pais: tons suaves, creme, profissional (estilo Family Link).
class AppColors {
  AppColors._();

  // ---- Área infantil (vibrante) ----
  static const Color kidsBlue = Color(0xFF2196F3);
  static const Color kidsGreen = Color(0xFF43C463);
  static const Color kidsYellow = Color(0xFFFFC42E);
  static const Color kidsPurple = Color(0xFF8B5CF6);
  static const Color kidsOrange = Color(0xFFFF8A3D);
  static const Color kidsCream = Color(0xFFFFF6E5);
  static const Color rewardGold = Color(0xFFFFD23F);

  // ---- Área dos pais (suave/profissional) ----
  static const Color parentBg = Color(0xFFFBF7EF); // creme claro
  static const Color parentBlue = Color(0xFF3F6FB0);
  static const Color parentBlueSoft = Color(0xFFD6E3F3);
  static const Color parentGreen = Color(0xFF6FB07F);
  static const Color parentPurple = Color(0xFF9A8BC4);
  static const Color parentSurface = Colors.white;
  static const Color parentGrey = Color(0xFFE6E3DC);
  static const Color parentText = Color(0xFF223A5E); // azul escuro

  // ---- Mundos ----
  static const Color worldAnimals = Color(0xFF7BC043);
  static const Color worldDinosaurs = Color(0xFFE07A3F);
  static const Color worldSpace = Color(0xFF5B6CC4);
  static const Color worldOcean = Color(0xFF2BB3C0);
  static const Color worldLibrary = Color(0xFFB9743F);

  // ---- Cores de pintura (jogo Colorir) ----
  static const List<Color> paintPalette = <Color>[
    Color(0xFFE53935), // vermelho
    Color(0xFF1E88E5), // azul
    Color(0xFFFDD835), // amarelo
    Color(0xFF43A047), // verde
    Color(0xFF8E24AA), // roxo
    Color(0xFFFB8C00), // laranja
    Color(0xFF6D4C41), // marrom
    Color(0xFF212121), // preto
  ];
}
