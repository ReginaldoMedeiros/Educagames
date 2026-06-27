import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pin_pad.dart';

/// Portão de PIN. Retorna `true` via [Navigator.pop] quando o PIN está correto.
///
/// Use o helper [requirePin] para proteger ações (entrar na área dos pais,
/// alterar configurações, conceder tempo extra, sair do modo infantil).
class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key, this.title = 'Digite o PIN dos pais'});

  final String title;

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  String? _error;

  void _onCompleted(String pin) {
    if (context.read<AppState>().verifyPin(pin)) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'PIN incorreto. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.parent(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: PinPad(
              title: widget.title,
              subtitle: 'Apenas os pais devem inserir o PIN.',
              onCompleted: _onCompleted,
              errorText: _error,
            ),
          ),
        ),
      ),
    );
  }
}

/// Abre o portão de PIN e retorna `true` se autenticado.
Future<bool> requirePin(BuildContext context,
    {String title = 'Digite o PIN dos pais'}) async {
  final bool? ok = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      fullscreenDialog: true,
      builder: (_) => PinEntryScreen(title: title),
    ),
  );
  return ok ?? false;
}
