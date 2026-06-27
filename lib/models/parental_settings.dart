/// Configurações de controle parental por perfil infantil.
///
/// Espelha a coleção `parentalSettings` sugerida para o Firestore.
class ParentalSettings {
  ParentalSettings({
    this.dailyLimitMinutes = 60,
    this.allowedStartHour = 8,
    this.allowedEndHour = 20,
    this.requirePinForSettings = true,
    this.requirePinToExitKidsArea = true,
  });

  /// Limites sugeridos: 15, 30, 60, 90, 120.
  int dailyLimitMinutes;

  /// Janela permitida (horas, 0-24). Padrão 08:00 às 20:00.
  int allowedStartHour;
  int allowedEndHour;

  bool requirePinForSettings;
  bool requirePinToExitKidsArea;

  String get allowedStartLabel =>
      '${allowedStartHour.toString().padLeft(2, '0')}:00';
  String get allowedEndLabel =>
      '${allowedEndHour.toString().padLeft(2, '0')}:00';

  /// Verdadeiro se [hour] (0-23) está dentro da janela permitida.
  bool isWithinAllowedHours(int hour) {
    if (allowedStartHour <= allowedEndHour) {
      return hour >= allowedStartHour && hour < allowedEndHour;
    }
    // Janela que cruza a meia-noite (ex.: 20 -> 6).
    return hour >= allowedStartHour || hour < allowedEndHour;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'dailyLimitMinutes': dailyLimitMinutes,
        'allowedStartHour': allowedStartHour,
        'allowedEndHour': allowedEndHour,
        'requirePinForSettings': requirePinForSettings,
        'requirePinToExitKidsArea': requirePinToExitKidsArea,
      };

  factory ParentalSettings.fromJson(Map<String, dynamic> json) {
    return ParentalSettings(
      dailyLimitMinutes: json['dailyLimitMinutes'] as int? ?? 60,
      allowedStartHour: json['allowedStartHour'] as int? ?? 8,
      allowedEndHour: json['allowedEndHour'] as int? ?? 20,
      requirePinForSettings: json['requirePinForSettings'] as bool? ?? true,
      requirePinToExitKidsArea:
          json['requirePinToExitKidsArea'] as bool? ?? true,
    );
  }
}
