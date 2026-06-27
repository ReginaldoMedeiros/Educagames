import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pin_pad.dart';
import '../profile_select_screen.dart';

/// Onboarding dos pais: criar PIN numérico de 4 dígitos (com confirmação).
/// É o primeiro passo obrigatório antes de usar o app.
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key, this.onDone});

  /// Se fornecido, chamado após salvar o PIN (ex.: troca de PIN). Caso
  /// contrário, segue para a seleção de perfil.
  final VoidCallback? onDone;

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String? _firstEntry;
  String? _error;

  Future<void> _onCompleted(String pin) async {
    if (_firstEntry == null) {
      setState(() {
        _firstEntry = pin;
        _error = null;
      });
      return;
    }
    if (_firstEntry != pin) {
      setState(() {
        _firstEntry = null;
        _error = 'Os PINs não coincidem. Tente novamente.';
      });
      return;
    }
    await context.read<AppState>().setPin(pin);
    if (!mounted) return;
    if (widget.onDone != null) {
      widget.onDone!();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ProfileSelectScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool confirming = _firstEntry != null;
    return Theme(
      data: AppTheme.parent(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: PinPad(
              key: ValueKey<bool>(confirming),
              title: confirming
                  ? 'Confirme o PIN dos pais'
                  : 'Crie o PIN dos pais',
              subtitle: confirming
                  ? 'Digite novamente os 4 dígitos.'
                  : 'Esse PIN protege o controle parental e as configurações.',
              onCompleted: _onCompleted,
              errorText: _error,
            ),
          ),
        ),
      ),
    );
  }
}
