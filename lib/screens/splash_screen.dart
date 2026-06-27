import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/corujao.dart';
import 'parent/pin_setup_screen.dart';
import 'profile_select_screen.dart';

/// Tela de abertura. Mostra o Mestre Corujão e decide o destino inicial:
///  - sem PIN cadastrado  -> onboarding dos pais (criar PIN).
///  - com PIN             -> seleção de perfil infantil.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideNext());
  }

  Future<void> _decideNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    final AppState state = context.read<AppState>();
    final Widget next =
        state.hasPin ? const ProfileSelectScreen() : const PinSetupScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[AppColors.kidsBlue, AppColors.kidsPurple],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Corujao(size: 160),
              SizedBox(height: 16),
              Text(
                'Educa Games',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Aprender brincando, no tempo certo.',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
