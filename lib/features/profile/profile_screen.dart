import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../data/models/user_model.dart';
import '../../data/models/user_role.dart';
import '../../data/repositories/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.onToggleTheme,
    required this.themeMode,
  });

  final AppUser user;
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Profile hero ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: PaeColors.heroGradient),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          UserAvatar(
                            initials: user.initials,
                            photoPath: user.photoPath,
                            radius: 44,
                            backgroundColor: Colors.white.withOpacity(0.25),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: PaeColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(user.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            fontFamily: PaeTypography.fontDisplay,
                          )),
                      const SizedBox(height: 4),
                      Text(user.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            fontFamily: PaeTypography.fontBody,
                          )),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_roleIcon(user.role),
                                color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(user.role.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: PaeTypography.fontBody,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Info cards ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: PaeColors.primary.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user.phone.isNotEmpty ? user.phone : '—'),
                    const Divider(height: 20),
                    _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'ID Number',
                        value: user.idNumber.isNotEmpty ? user.idNumber : '—'),
                    if (user.institution != null &&
                        user.institution!.isNotEmpty) ...[
                      const Divider(height: 20),
                      _InfoRow(
                          icon: Icons.school_outlined,
                          label: 'Institution',
                          value: user.institution!),
                    ],
                    const Divider(height: 20),
                    _InfoRow(
                      icon: Icons.cloud_outlined,
                      label: 'Sync status',
                      value: user.isSynced ? 'Synced' : 'Pending sync',
                      valueColor: user.isSynced ? PaeColors.success : PaeColors.warning,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Settings ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    label: S.settingsTheme,
                    trailing: Switch.adaptive(
                      value: isDark,
                      onChanged: (_) => onToggleTheme(),
                      activeColor: PaeColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    label: S.profileNotifications,
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: PaeColors.inactive),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(S.comingSoon))),
                  ),
                  const SizedBox(height: 8),
                  _SettingsTile(
                    icon: Icons.sync_rounded,
                    label: S.settingsSync,
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: PaeColors.inactive),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(S.settingsSyncDone))),
                  ),
                  const SizedBox(height: 24),

                  // Logout
                  GestureDetector(
                    onTap: () => _confirmLogout(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: PaeColors.error.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: PaeColors.error.withOpacity(0.2)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded,
                              color: PaeColors.error, size: 20),
                          SizedBox(width: 10),
                          Text(S.profileLogout,
                              style: TextStyle(
                                color: PaeColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                fontFamily: PaeTypography.fontBody,
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text('PAEGo v2.0.0',
                      style: TextStyle(
                          color: PaeColors.inactive, fontSize: 12)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.superAdmin: return Icons.admin_panel_settings_rounded;
      case UserRole.admin:      return Icons.manage_accounts_rounded;
      case UserRole.rector:     return Icons.school_rounded;
      case UserRole.driver:     return Icons.local_shipping_rounded;
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(S.profileLogout,
            style: TextStyle(
                fontFamily: PaeTypography.fontDisplay,
                fontWeight: FontWeight.w800)),
        content: const Text(S.profileLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.instance.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRouter.login, (_) => false);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: PaeColors.error),
            child: const Text(S.yes),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: PaeColors.primary),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
              color: PaeColors.textSecondary,
              fontSize: 13,
              fontFamily: PaeTypography.fontBody,
            )),
        const Spacer(),
        Text(value,
            style: TextStyle(
              color: valueColor ?? PaeColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              fontFamily: PaeTypography.fontBody,
            )),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PaeColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PaeColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: PaeColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: PaeTypography.fontBody,
                  )),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
