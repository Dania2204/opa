import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../data/models/user_model.dart';
import '../../data/models/user_role.dart';
import '../../data/repositories/auth_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../map/map_screen.dart';
import '../reports/reports_screen.dart';
import '../personnel/personnel_screen.dart';
import '../profile/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.user,
    required this.onToggleTheme,
    required this.themeMode,
  });

  final AppUser user;
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  late final List<_TabDef> _tabs;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _tabs = [
      _TabDef(
        icon: Icons.dashboard_rounded,
        label: S.navHome,
        screen: DashboardScreen(user: u),
      ),
      _TabDef(
        icon: Icons.map_rounded,
        label: S.navMap,
        screen: MapScreen(user: u),
      ),
      _TabDef(
        icon: Icons.assignment_rounded,
        label: S.navReports,
        screen: ReportsScreen(user: u),
      ),
      if (u.role.canManagePersonnel)
        _TabDef(
          icon: Icons.people_rounded,
          label: S.personnelTitle,
          screen: PersonnelScreen(user: u),
        ),
      _TabDef(
        icon: Icons.person_rounded,
        label: S.navProfile,
        screen: ProfileScreen(
          user: u,
          onToggleTheme: widget.onToggleTheme,
          themeMode: widget.themeMode,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: PaeColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: _tabs
              .map((t) => BottomNavigationBarItem(
                    icon: Icon(t.icon),
                    label: t.label,
                  ))
              .toList(),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

class _TabDef {
  const _TabDef({
    required this.icon,
    required this.label,
    required this.screen,
  });

  final IconData icon;
  final String label;
  final Widget screen;
}
