import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/storage_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Todo o app é em modo paisagem (landscape).
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // Imersivo: esconde barras do sistema para foco total da criança.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final StorageService storage = await StorageService.create();

  runApp(
    ChangeNotifierProvider<AppState>(
      create: (_) => AppState(storage),
      child: const EducaGamesApp(),
    ),
  );
}
