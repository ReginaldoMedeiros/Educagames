import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/child_profile.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_view.dart';
import '../widgets/corujao.dart';
import 'hub_screen.dart';
import 'parent/parental_dashboard_screen.dart';
import 'parent/pin_entry_screen.dart';
import 'profile_create_screen.dart';

/// Seleção/criação de perfil infantil. Também dá acesso à Área dos Pais
/// (protegida por PIN).
class ProfileSelectScreen extends StatelessWidget {
  const ProfileSelectScreen({super.key});

  Future<void> _openParentArea(BuildContext context) async {
    final bool ok = await requirePin(context, title: 'Acesso à Área dos Pais');
    if (!ok || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ParentalDashboardScreen()),
    );
  }

  Future<void> _select(BuildContext context, ChildProfile p) async {
    final AppState state = context.read<AppState>();
    await state.selectProfile(p.id);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const HubScreen()),
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
            colors: <Color>[AppColors.kidsCream, Color(0xFFFFE9C7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: <Widget>[
                    const Corujao(size: 64),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Quem vai explorar hoje?',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openParentArea(context),
                      icon: const Icon(Icons.shield_rounded),
                      label: const Text('Área dos Pais'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<AppState>(
                  builder: (BuildContext context, AppState state, _) {
                    final List<ChildProfile> profiles = state.profiles;
                    return Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            for (final ChildProfile p in profiles)
                              _ProfileCard(
                                profile: p,
                                onTap: () => _select(context, p),
                                onDelete: () =>
                                    _confirmDelete(context, state, p),
                              ),
                            _AddProfileCard(
                              enabled: state.canAddProfile,
                              maxReachedHint: state.premium
                                  ? 'Máximo de 5 perfis'
                                  : 'Plano gratuito: 1 perfil',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, AppState state, ChildProfile p) async {
    final bool ok = await requirePin(context, title: 'Confirme para excluir');
    if (!ok || !context.mounted) return;
    await state.deleteProfile(p.id);
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.onTap,
    required this.onDelete,
  });

  final ChildProfile profile;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onDelete,
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AvatarView(profile: profile, size: 110),
              const SizedBox(height: 12),
              Text(profile.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.star_rounded,
                      color: AppColors.rewardGold, size: 18),
                  const SizedBox(width: 4),
                  Text('${profile.stars}'),
                  const SizedBox(width: 12),
                  Text('Nível ${profile.level}',
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddProfileCard extends StatelessWidget {
  const _AddProfileCard({required this.enabled, required this.maxReachedHint});

  final bool enabled;
  final String maxReachedHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: enabled
            ? () async {
                // Adicionar perfil exige PIN (proteção dos pais).
                final bool ok = await requirePin(context,
                    title: 'Adicionar perfil exige PIN');
                if (!ok || !context.mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const ProfileCreateScreen()),
                );
              }
            : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Container(
            width: 180,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: AppColors.kidsBlue, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.add_circle_rounded,
                    size: 64, color: AppColors.kidsBlue),
                const SizedBox(height: 12),
                const Text('Adicionar Perfil',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                if (!enabled) ...<Widget>[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(maxReachedHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
