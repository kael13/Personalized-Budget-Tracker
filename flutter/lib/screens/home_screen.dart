import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/app_state.dart';
import '../models/budget_models.dart';
import '../widgets/budget_card_widget.dart';
import '../dialogs/budget_modal.dart';
import '../dialogs/detail_sheet.dart';
import '../dialogs/pin_lock_dialog.dart';
import '../screens/analytics_screen.dart';
import '../screens/calculator_screen.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _sortBy = 'date'; // 'date' or 'amount'

  void _openBudgetModal(BuildContext context, {BudgetAllocation? initialData}) {
    final appState = Provider.of<AppState>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BudgetModal(
          initialData: initialData,
          onClose: () => Navigator.pop(context),
          onSave: (budget) {
            appState.saveBudget(budget);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(initialData != null
                    ? 'Profile updated successfully! ✨'
                    : 'Profile created successfully! 🎀'),
              ),
            );
          },
        );
      },
    );
  }

  void _openDetailSheet(BuildContext context, BudgetAllocation budget) {
    final appState = Provider.of<AppState>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DetailSheet(
          budget: budget,
          onClose: () => Navigator.pop(context),
          onEdit: () {
            Navigator.pop(context);
            _openBudgetModal(context, initialData: budget);
          },
          onDelete: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Delete Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                content: const Text('Are you sure you want to delete this budget profile? ✨'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await appState.deleteBudget(budget.id);
              if (context.mounted) Navigator.pop(context);
            }
          },
          onUpdate: (updated) async {
            await appState.saveBudget(updated);
          },
        );
      },
    );
  }

  void _handleBudgetClick(BuildContext context, BudgetAllocation budget) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.isEditMode) {
      appState.toggleSelectBudget(budget.id);
      return;
    }

    // Verify PIN Lock if set
    if (budget.pin != null && budget.pin!.isNotEmpty) {
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        pageBuilder: (context, anim1, anim2) {
          return PinLockDialog(
            correctPin: budget.pin!,
            onSuccess: () {
              Navigator.pop(context); // Close PIN Dialog
              _openDetailSheet(context, budget);
            },
            onCancel: () {
              Navigator.pop(context); // Close PIN Dialog
            },
          );
        },
      );
    } else {
      _openDetailSheet(context, budget);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter and Sort budgets
    final filteredBudgets = appState.budgets.where((b) {
      return b.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    filteredBudgets.sort((a, b) {
      // Pinned entries always on top
      final aPinned = a.pin != null && a.pin!.isNotEmpty;
      final bPinned = b.pin != null && b.pin!.isNotEmpty;
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;

      if (_sortBy == 'date') {
        return b.createdAt.compareTo(a.createdAt);
      } else {
        return b.totalBudget.compareTo(a.totalBudget);
      }
    });

    Widget bodyWidget;
    if (appState.activeTab == 'analytics') {
      bodyWidget = const AnalyticsScreen();
    } else if (appState.activeTab == 'calculator') {
      bodyWidget = const CalculatorScreen();
    } else {
      bodyWidget = _buildDashboard(context, appState, filteredBudgets, isDark);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom Royal App Bar
            _buildAppBar(context, appState, isDark),

            // Main display body
            Expanded(child: bodyWidget),

            // Bulk edit action bar overlay if edit mode is active
            if (appState.isEditMode && appState.activeTab == 'dashboard')
              _buildBulkActionBar(context, appState, isDark),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, appState, isDark),
      floatingActionButton: (appState.activeTab == 'dashboard' && !appState.isEditMode)
          ? FloatingActionButton(
              onPressed: () => _openBudgetModal(context),
              backgroundColor: AppColors.pastelPink,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ).animate().scale(delay: 200.ms)
          : null,
    );
  }

  // APP BAR
  Widget _buildAppBar(BuildContext context, AppState appState, bool isDark) {
    final formattedDate = DateFormat('MMMM d, y').format(DateTime.now()).toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                appState.activeTab == 'dashboard'
                    ? 'Bloom Budget'
                    : appState.activeTab == 'analytics'
                        ? 'Visual Insights'
                        : 'Calculator Standard',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.slate700,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Dashboard edit actions
              if (appState.activeTab == 'dashboard' && appState.budgets.isNotEmpty) ...[
                GestureDetector(
                  onTap: () => appState.toggleEditMode(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: appState.isEditMode
                          ? AppColors.pastelPink
                          : AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      appState.isEditMode ? Icons.edit_off_outlined : Icons.edit_outlined,
                      size: 18,
                      color: appState.isEditMode ? Colors.white : AppColors.pastelPinkDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Dark Mode toggle
              GestureDetector(
                onTap: () => appState.toggleDarkMode(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    size: 18,
                    color: AppColors.pastelPinkDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BOTTOM NAVIGATION BAR
  Widget _buildBottomNav(BuildContext context, AppState appState, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.slate800 : AppColors.slate100,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: Icons.layers_outlined,
            activeIcon: Icons.layers,
            label: 'Plans',
            isActive: appState.activeTab == 'dashboard',
            onTap: () => appState.setActiveTab('dashboard'),
            isDark: isDark,
          ),
          _navItem(
            icon: Icons.auto_awesome_outlined,
            activeIcon: Icons.auto_awesome,
            label: 'Analytics',
            isActive: appState.activeTab == 'analytics',
            onTap: () => appState.setActiveTab('analytics'),
            isDark: isDark,
          ),
          _navItem(
            icon: Icons.calculate_outlined,
            activeIcon: Icons.calculate,
            label: 'Math Engine',
            isActive: appState.activeTab == 'calculator',
            onTap: () => appState.setActiveTab('calculator'),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppColors.pastelPinkDark
                  : (isDark ? AppColors.slate500 : AppColors.slate400),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: isActive
                    ? AppColors.pastelPinkDark
                    : (isDark ? AppColors.slate500 : AppColors.slate400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BULK ACTION BAR
  Widget _buildBulkActionBar(BuildContext context, AppState appState, bool isDark) {
    final count = appState.selectedBudgetIds.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.slate800 : AppColors.slate100,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count Selected',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.slate700,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: count > 0 ? () => appState.bulkPinToggle() : null,
                child: Text(
                  'Pin/Unpin',
                  style: TextStyle(
                    color: count > 0 ? AppColors.pastelPinkDark : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: count > 0
                    ? () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Selected', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                            content: Text('Are you sure you want to delete these $count selected budgets? ✨'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await appState.deleteSelectedBudgets();
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  disabledBackgroundColor: isDark ? AppColors.slate800 : Colors.grey.shade200,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ).animate().slideY(begin: 0.5),
    );
  }

  // DASHBOARD TAB
  Widget _buildDashboard(
    BuildContext context,
    AppState appState,
    List<BudgetAllocation> filteredBudgets,
    bool isDark,
  ) {
    if (appState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.pastelPink),
      );
    }

    if (appState.budgets.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_florist_outlined, size: 80, color: AppColors.pastelPink.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'No budget plans yet ✨',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.slate500 : AppColors.slate450,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _openBudgetModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pastelPink,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start Growing Your Savings',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Welcome Card (Optional parity header highlight)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.pastelPink,
                  AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.35 : 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR SAVINGS HAVEN',
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Grow your wealth elegantly! 🌸',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
        ),

        // Search Bar & Sort controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Row(
            children: [
              // Search input
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate900 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.slate800 : AppColors.slate150,
                    ),
                  ),
                  child: TextFormField(
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.slate700,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search budgets...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.slate500 : AppColors.slate300,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 16,
                        color: isDark ? AppColors.slate500 : AppColors.slate300,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Sort dropdown selection
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate900 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.slate800 : AppColors.slate150,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    dropdownColor: isDark ? AppColors.slate900 : Colors.white,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.slate700,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('DATE')),
                      DropdownMenuItem(value: 'amount', child: Text('AMOUNT')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _sortBy = val;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // List Scroll Area of Cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: filteredBudgets.length,
            itemBuilder: (context, index) {
              final budget = filteredBudgets[index];
              final isSel = appState.selectedBudgetIds.contains(budget.id);

              return BudgetCardWidget(
                allocation: budget,
                onClick: () => _handleBudgetClick(context, budget),
                isSelected: isSel,
                onToggleSelect: appState.isEditMode
                    ? () => appState.toggleSelectBudget(budget.id)
                    : null,
                onDelete: (!appState.isEditMode)
                    ? () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                            content: const Text('Are you sure you want to delete this budget profile? ✨'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await appState.deleteBudget(budget.id);
                        }
                      }
                    : null,
              ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.05);
            },
          ),
        ),
      ],
    );
  }
}

// Ext helpers
extension AppColorsHelper6 on AppColors {
  static Color slate150() => const Color(0xFFE2E8F0);
}
