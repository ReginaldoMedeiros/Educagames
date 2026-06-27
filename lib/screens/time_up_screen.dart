import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/corujao.dart';
import 'parent/pin_entry_screen.dart';

/// Tela de tempo encerrado. Não bloqueia totalmente o app: a criança ainda
/// pode ver avatar, álbum e conquistas. Mensagem positiva do Mestre Corujão.
/// Os pais podem adicionar tempo extra mediante PIN.
class TimeUpScreen extends StatelessWidget {
  const TimeUpScreen({super.key});

  Future<void> _addTime(BuildContext context) async {
    final bool ok =
        await requirePin(context, title: 'Adicionar tempo exige PIN');
    if (!ok || !context.mounted) return;
    final int? minutes = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Quanto tempo extra liberar?',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              for (final int m in <int>[15, 30, 60])
                ListTile(
                  leading: const Icon(Icons.add_alarm_rounded),
                  title: Text('+$m minutos'),
                  onTap: () => Navigator.of(context).pop(m),
                ),
            ],
          ),
        );
      },
    );
    if (minutes == null || !context.mounted) return;
    await context.read<AppState>().grantExtraTime(minutes);
    if (!context.mounted) return;
    // Com tempo liberado, volta para a área infantil.
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tempo extra de $minutes minutos liberado!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFFFF1C9), AppColors.kidsCream],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CorujaoMessage(
                    message:
                        'Hoje você explorou bastante. Amanhã teremos novas descobertas!',
                    size: 120,
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.kidsBlue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Entendi'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _addTime(context),
                        icon: const Icon(Icons.lock_clock_rounded),
                        label: const Text('Adicionar Tempo (Pais)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
