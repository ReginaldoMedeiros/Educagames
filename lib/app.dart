import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

/// Raiz do aplicativo. Tema infantil como padrão; a área dos pais aplica o
/// tema [AppTheme.parent] localmente via [Theme].
class EducaGamesApp extends StatelessWidget {
  const EducaGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educa Games',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.kids(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const <Locale>[Locale('pt', 'BR')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
