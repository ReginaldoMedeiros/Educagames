import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/child_profile.dart';
import '../models/world.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/avatar_view.dart';
import '../widgets/common_widgets.dart';
import 'achievements_screen.dart';
import 'album_screen.dart';
import 'avatar_screen.dart';
import 'child_profile_screen.dart';
import 'parent/parental_dashboard_screen.dart';
import 'parent/pin_entry_screen.dart';
import 'time_up_screen.dart';
import 'world_screen.dart';

/// Biblioteca Central — hub principal da área infantil.
///
/// Inicia a contagem de tempo ativo e aplica as regras de controle de tempo:
/// fora do horário permitido ou sem tempo disponível, os jogos ficam bloqueados
/// (mas avatar, álbum e conquistas continuam acessíveis).
class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<AppState>().startUsageTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<AppState>().stopUsageTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pausa a contagem em background; retoma em foreground (tempo ativo).
    final AppState app = context.read<AppState>();
    if (state == AppLifecycleState.resumed) {
      app.startUsageTimer();
    } else {
      app.stopUsageTimer();
    }
  }

  Future<void> _exitKidsArea() async {
    final AppState app = context.read<AppState>();
    final ChildProfile? p = app.activeProfile;
    final bool requirePinExit =
        p?.settings.requirePinToExitKidsArea ?? true;
    if (requirePinExit) {
      final bool ok = await requirePin(context, title: 'Sair exige PIN');
      if (!ok) return;
    }
    if (!mounted) return;
    await app.clearActiveProfile();
    if (!mounted) return;
    Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
  }

  void _openWorld(World world) {
    final AppState app = context.read<AppState>();
    if (!app.canPlayGames) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const TimeUpScreen()),
      );
      return;
    }
    if (!app.isWorldUnlocked(world)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Continue explorando! ${world.name} abre com ${world.starsToUnlock} estrelas.'),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'world'),
        builder: (_) => WorldScreen(world: world),
      ),
    );
  }

  Future<void> _openParentArea() async {
    final bool ok = await requirePin(context, title: 'Área dos Pais');
    if (!ok || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ParentalDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState app, _) {
        final ChildProfile? p = app.activeProfile;
        if (p == null) {
          return const Scaffold(body: SizedBox.shrink());
        }
        return Scaffold(
          body: GradientBackground(
            color: AppColors.kidsBlue,
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  _topBar(context, app, p),
                  if (!app.canPlayGames) _timeBanner(context, app),
                  Expanded(child: _portals(app)),
                  _bottomMenu(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _topBar(BuildContext context, AppState app, ChildProfile p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const ChildProfileScreen())),
            child: Row(
              children: <Widget>[
                AvatarView(profile: p, size: 52),
                const SizedBox(width: 10),
                Text(p.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const Spacer(),
          CurrencyChip(
              icon: Icons.star_rounded,
              value: p.stars,
              color: AppColors.rewardGold),
          const SizedBox(width: 8),
          CurrencyChip(
              icon: Icons.monetization_on_rounded,
              value: p.coins,
              color: AppColors.kidsOrange),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Área dos Pais',
            onPressed: _openParentArea,
            icon: const Icon(Icons.shield_rounded, color: AppColors.parentBlue),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: _exitKidsArea,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
    );
  }

  Widget _timeBanner(BuildContext context, AppState app) {
    final String msg = app.isWithinAllowedHours
        ? 'Tempo de hoje encerrado. Você ainda pode ver seu avatar, álbum e conquistas!'
        : 'Fora do horário permitido. Combine com os pais o melhor momento para explorar!';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.kidsYellow.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.access_time_rounded),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _portals(AppState app) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: <Widget>[
            for (final World w in kWorlds)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: BigIconButton(
                  icon: w.icon,
                  label: w.name,
                  color: w.color,
                  locked: !app.isWorldUnlocked(w),
                  onTap: () => _openWorld(w),
                  size: 150,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bottomMenu(BuildContext context) {
    Widget item(IconData icon, String label, Color color, Widget page) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => page)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 28),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: <Widget>[
          item(Icons.checkroom_rounded, 'Avatar', AppColors.kidsPurple,
              const AvatarScreen()),
          item(Icons.collections_bookmark_rounded, 'Álbum',
              AppColors.kidsGreen, const AlbumScreen()),
          item(Icons.emoji_events_rounded, 'Conquistas', AppColors.kidsOrange,
              const AchievementsScreen()),
          item(Icons.person_rounded, 'Perfil', AppColors.kidsBlue,
              const ChildProfileScreen()),
        ],
      ),
    );
  }
}
