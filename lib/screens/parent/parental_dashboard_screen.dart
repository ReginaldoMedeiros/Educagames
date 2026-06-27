import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/child_profile.dart';
import '../../models/parental_settings.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../profile_create_screen.dart';
import 'pin_entry_screen.dart';
import 'pin_setup_screen.dart';

/// Área dos Pais — principal diferencial comercial. Visual profissional,
/// limpo, em português, no estilo Family Link.
class ParentalDashboardScreen extends StatefulWidget {
  const ParentalDashboardScreen({super.key});

  @override
  State<ParentalDashboardScreen> createState() =>
      _ParentalDashboardScreenState();
}

class _ParentalDashboardScreenState extends State<ParentalDashboardScreen> {
  String? _selectedId;

  ChildProfile? _selected(AppState app) {
    final List<ChildProfile> profiles = app.profiles;
    if (profiles.isEmpty) return null;
    _selectedId ??= app.activeProfile?.id ?? profiles.first.id;
    return profiles.firstWhere((ChildProfile p) => p.id == _selectedId,
        orElse: () => profiles.first);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.parent(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Controle Parental'),
          actions: <Widget>[
            Consumer<AppState>(
              builder: (BuildContext context, AppState app, _) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Chip(
                      avatar: Icon(
                        app.premium
                            ? Icons.workspace_premium_rounded
                            : Icons.lock_open_rounded,
                        size: 18,
                      ),
                      label: Text(app.premium ? 'Premium' : 'Gratuito'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<AppState>(
          builder: (BuildContext context, AppState app, _) {
            final List<ChildProfile> profiles = app.profiles;
            if (profiles.isEmpty) {
              return _EmptyState();
            }
            final ChildProfile child = _selected(app)!;
            final ParentalSettings s = child.settings;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                _profileSelector(app, profiles, child),
                const SizedBox(height: 16),
                _playingNowCard(app),
                const SizedBox(height: 16),
                _usageCard(app, child),
                const SizedBox(height: 16),
                _weeklyReportCard(app, child),
                const SizedBox(height: 16),
                _dailyLimitCard(app, child, s),
                const SizedBox(height: 16),
                _allowedHoursCard(app, child, s),
                const SizedBox(height: 16),
                _extraTimeCard(app, child),
                const SizedBox(height: 16),
                _pinCard(app, child, s),
                const SizedBox(height: 16),
                _planCard(app),
                const SizedBox(height: 16),
                _profilesCard(app, profiles),
              ],
            );
          },
        ),
      ),
    );
  }

  // ----------------------------------------------------------- componentes
  Widget _sectionCard({required String title, IconData? icon, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, color: AppColors.parentBlue),
                  const SizedBox(width: 8),
                ],
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _profileSelector(
      AppState app, List<ChildProfile> profiles, ChildProfile selected) {
    return Wrap(
      spacing: 8,
      children: <Widget>[
        for (final ChildProfile p in profiles)
          ChoiceChip(
            label: Text(p.name),
            selected: p.id == selected.id,
            onSelected: (_) => setState(() => _selectedId = p.id),
          ),
      ],
    );
  }

  Widget _playingNowCard(AppState app) {
    final ChildProfile? active = app.activeProfile;
    return _sectionCard(
      title: 'Jogando Agora',
      icon: Icons.videogame_asset_rounded,
      child: Row(
        children: <Widget>[
          Icon(
            active != null ? Icons.person_rounded : Icons.person_off_rounded,
            color: active != null ? AppColors.parentGreen : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            active != null
                ? '${active.name} está na área infantil'
                : 'Nenhuma criança jogando no momento',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _usageCard(AppState app, ChildProfile child) {
    final int used = app.usageForProfileToday(child.id);
    final int limit = child.settings.dailyLimitMinutes;
    final double ratio = limit == 0 ? 0 : (used / limit).clamp(0, 1);
    return _sectionCard(
      title: 'Uso de Hoje',
      icon: Icons.today_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('$used de $limit minutos utilizados',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 14,
              backgroundColor: AppColors.parentGrey,
              color: ratio >= 1 ? Colors.redAccent : AppColors.parentGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyReportCard(AppState app, ChildProfile child) {
    final List<int> week = app.weeklyUsage(child.id);
    final int maxV =
        week.isEmpty ? 1 : (week.reduce((int a, int b) => a > b ? a : b));
    const List<String> labels = <String>['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return _sectionCard(
      title: 'Relatório Semanal',
      icon: Icons.bar_chart_rounded,
      child: SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (int i = 0; i < 7; i++)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text('${week[i]}',
                        style: const TextStyle(fontSize: 11)),
                    const SizedBox(height: 4),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: maxV == 0
                          ? 4
                          : (80 * (week[i] / maxV)).clamp(4, 80).toDouble(),
                      decoration: BoxDecoration(
                        color: AppColors.parentBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(labels[i % 7],
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dailyLimitCard(
      AppState app, ChildProfile child, ParentalSettings s) {
    return _sectionCard(
      title: 'Limite Diário',
      icon: Icons.hourglass_bottom_rounded,
      child: Wrap(
        spacing: 8,
        children: <Widget>[
          for (final int m in <int>[15, 30, 60, 90, 120])
            ChoiceChip(
              label: Text('$m min'),
              selected: s.dailyLimitMinutes == m,
              onSelected: (_) =>
                  app.updateSettings(child.id, dailyLimitMinutes: m),
            ),
        ],
      ),
    );
  }

  Widget _allowedHoursCard(
      AppState app, ChildProfile child, ParentalSettings s) {
    return _sectionCard(
      title: 'Horário Permitido',
      icon: Icons.schedule_rounded,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _HourStepper(
              label: 'Início',
              hour: s.allowedStartHour,
              onChanged: (int h) =>
                  app.updateSettings(child.id, allowedStartHour: h),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _HourStepper(
              label: 'Fim',
              hour: s.allowedEndHour,
              onChanged: (int h) =>
                  app.updateSettings(child.id, allowedEndHour: h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _extraTimeCard(AppState app, ChildProfile child) {
    return _sectionCard(
      title: 'Tempo Extra',
      icon: Icons.add_alarm_rounded,
      child: Wrap(
        spacing: 8,
        children: <Widget>[
          for (final int m in <int>[15, 30, 60])
            OutlinedButton.icon(
              onPressed: () async {
                await app.grantExtraTime(m, profileId: child.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('+$m min liberados para ${child.name}.')),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: Text('+$m min'),
            ),
        ],
      ),
    );
  }

  Widget _pinCard(AppState app, ChildProfile child, ParentalSettings s) {
    return _sectionCard(
      title: 'Proteção por PIN',
      icon: Icons.lock_rounded,
      child: Column(
        children: <Widget>[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Exigir PIN para alterar configurações'),
            value: s.requirePinForSettings,
            onChanged: (bool v) =>
                app.updateSettings(child.id, requirePinForSettings: v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Exigir PIN para sair do modo infantil'),
            value: s.requirePinToExitKidsArea,
            onChanged: (bool v) =>
                app.updateSettings(child.id, requirePinToExitKidsArea: v),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () async {
                final bool ok = await requirePin(context,
                    title: 'Confirme o PIN atual');
                if (!ok || !context.mounted) return;
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => PinSetupScreen(
                    onDone: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN atualizado.')),
                      );
                    },
                  ),
                ));
              },
              icon: const Icon(Icons.password_rounded),
              label: const Text('Trocar PIN'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard(AppState app) {
    return _sectionCard(
      title: 'Plano',
      icon: Icons.workspace_premium_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            app.premium
                ? 'Premium: até 5 perfis, sem anúncios, todo o conteúdo liberado.'
                : 'Gratuito: 1 perfil, conteúdo limitado, anúncios. Premium por R\$ 9,90/mês.',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ativar Premium (simulado no MVP)'),
            subtitle: const Text(
                'A arquitetura está pronta para assinatura real via loja/Firebase.'),
            value: app.premium,
            onChanged: (bool v) => app.setPremium(v),
          ),
        ],
      ),
    );
  }

  Widget _profilesCard(AppState app, List<ChildProfile> profiles) {
    return _sectionCard(
      title: 'Perfis Infantis',
      icon: Icons.family_restroom_rounded,
      child: Column(
        children: <Widget>[
          for (final ChildProfile p in profiles)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_rounded),
              title: Text(p.name),
              subtitle: Text(
                  '${p.age != null ? '${p.age} anos • ' : ''}${p.stars} estrelas • Nível ${p.level}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => app.deleteProfile(p.id),
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: app.canAddProfile
                  ? () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => const ProfileCreateScreen()))
                  : null,
              icon: const Icon(Icons.add_rounded),
              label: Text(app.canAddProfile
                  ? 'Adicionar Perfil'
                  : 'Limite de perfis atingido (${app.maxProfiles})'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.family_restroom_rounded,
                size: 72, color: AppColors.parentBlue),
            const SizedBox(height: 16),
            const Text('Nenhum perfil infantil ainda',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Crie o primeiro perfil para começar a configurar.',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const ProfileCreateScreen()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Adicionar Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourStepper extends StatelessWidget {
  const _HourStepper({
    required this.label,
    required this.hour,
    required this.onChanged,
  });

  final String label;
  final int hour;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            IconButton(
              onPressed: () => onChanged((hour - 1) % 24 < 0 ? 23 : (hour - 1) % 24),
              icon: const Icon(Icons.remove_circle_outline_rounded),
            ),
            Text('${hour.toString().padLeft(2, '0')}:00',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            IconButton(
              onPressed: () => onChanged((hour + 1) % 24),
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
          ],
        ),
      ],
    );
  }
}
