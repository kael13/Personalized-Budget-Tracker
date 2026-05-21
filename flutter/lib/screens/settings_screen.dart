import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
    if (xFile != null) {
      if (!mounted) return;
      await context.read<AppState>().setProfilePicture(xFile.path);
    }
  }

  void _showImagePickerSheet() {
    final appState = context.read<AppState>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate700 : AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Profile Picture',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.slate700,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.pastelPinkDark),
                title: Text('Take Photo', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.pastelPinkDark),
                title: Text('Choose from Gallery', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (appState.profilePicturePath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: Text('Remove Photo', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(ctx);
                    appState.removeProfilePicture();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.slate950 : AppColors.backgroundSoft,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.pastelPinkDark),
          ),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.slate700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 8),
          _buildProfileSection(context, appState, isDark),
          const SizedBox(height: 24),
          _buildNotificationSection(context, appState, isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, AppState appState, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? const Color(0x33FFB6C1) : const Color(0x1BFFB6C1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePickerSheet,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.2 : 0.5),
                    border: Border.all(color: AppColors.pastelPink, width: 3),
                    image: appState.profilePicturePath != null
                        ? DecorationImage(
                            image: FileImage(File(appState.profilePicturePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: appState.profilePicturePath == null
                      ? Icon(Icons.person_outline, size: 48, color: AppColors.pastelPinkDark.withValues(alpha: 0.6))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.pastelPinkDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.slate400 : AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, AppState appState, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? const Color(0x33FFB6C1) : const Color(0x1BFFB6C1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOTIFICATIONS',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: AppColors.pastelPinkDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchRow(
            icon: Icons.notifications_outlined,
            title: 'Enable Notifications',
            subtitle: 'Master toggle for all notifications',
            value: appState.notificationsEnabled,
            onChanged: (val) => appState.setNotificationsEnabled(val),
            isDark: isDark,
          ),
          const Divider(height: 24),
          _buildSwitchRow(
            icon: Icons.trending_up,
            title: 'Spending Alerts',
            subtitle: 'Warn at 80% and when exceeded',
            value: appState.notifThresholdAlerts,
            onChanged: appState.notificationsEnabled ? (val) => appState.setNotifThresholdAlerts(val) : null,
            isDark: isDark,
          ),
          const Divider(height: 24),
          _buildSwitchRow(
            icon: Icons.calendar_today_outlined,
            title: 'Daily Reminder',
            subtitle: appState.notifDailyReminderTime.format(context),
            value: appState.notifDailyReminder,
            onChanged: appState.notificationsEnabled ? (val) => appState.setNotifDailyReminder(val) : null,
            isDark: isDark,
            onSubtitleTap: appState.notificationsEnabled && appState.notifDailyReminder
                ? () => _pickReminderTime(appState)
                : null,
          ),
          const Divider(height: 24),
          _buildSwitchRow(
            icon: Icons.timer_outlined,
            title: 'Expiry Warnings',
            subtitle: 'Alert when \u22643 days remaining',
            value: appState.notifExpiryWarnings,
            onChanged: appState.notificationsEnabled ? (val) => appState.setNotifExpiryWarnings(val) : null,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    ValueChanged<bool>? onChanged,
    VoidCallback? onSubtitleTap,
  }) {
    final bool disabled = onChanged == null;
    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.pastelPinkDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: onSubtitleTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.slate700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.slate400 : AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.pastelPink,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Future<void> _pickReminderTime(AppState appState) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: appState.notifDailyReminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.pastelPinkDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      await appState.setNotifDailyReminderTime(picked);
    }
  }
}
