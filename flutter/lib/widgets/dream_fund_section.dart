import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/savings_goal_model.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import 'dream_fund_modal.dart';
import 'add_to_fund_sheet.dart';

class DreamFundSection extends StatelessWidget {
  const DreamFundSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = Provider.of<AppState>(context);
    final goals = appState.savingsGoals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DREAM FUNDS \u{2728}',
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                ),
              ),
              GestureDetector(
                onTap: () => _showCreateModal(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.pastelPink.withValues(alpha: isDark ? 0.15 : 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 14, color: AppColors.pastelPinkDark),
                      const SizedBox(width: 2),
                      Text(
                        'NEW',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.pastelPinkDark,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: goals.isEmpty
              ? _buildEmptyCard(context, isDark)
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: goals.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == goals.length) {
                      return _buildAddCard(context, isDark);
                    }
                    return _buildGoalCard(context, goals[index], isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingsGoal goal, bool isDark) {
    final progress = goal.progress;
    final daysLeft = goal.daysLeft;
    final isComplete = goal.isComplete;

    return GestureDetector(
      onTap: () => _showAddSheet(context, goal),
      onLongPress: () => _showOptions(context, goal),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate850 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isComplete
                ? Colors.green.withValues(alpha: 0.4)
                : AppColors.pastelPink.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.pastelPink.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  goal.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.name,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.slate700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'PHP ${goal.savedAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.pastelPinkDark,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: isDark ? AppColors.slate950 : AppColors.slate100,
                color: isComplete ? Colors.green : AppColors.pastelPink,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isComplete
                  ? 'COMPLETE! \u{1F31F}'
                  : '$daysLeft day${daysLeft == 1 ? "" : "s"} left',
              style: GoogleFonts.outfit(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: isComplete
                    ? Colors.green
                    : (isDark ? AppColors.slate500 : AppColors.slate400),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _showCreateModal(context),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.pastelPink.withValues(alpha: isDark ? 0.08 : 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.pastelPink.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, size: 28, color: AppColors.pastelPinkDark),
            const SizedBox(height: 4),
            Text(
              'New Fund',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.pastelPinkDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _showCreateModal(context),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.pastelPink.withValues(alpha: isDark ? 0.06 : 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.pastelPink.withValues(alpha: 0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_outlined, size: 28, color: AppColors.pastelPinkDark),
            const SizedBox(height: 8),
            Text(
              'Start a Dream Fund \u{2728}',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.pastelPinkDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Save towards something special!',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: isDark ? AppColors.slate500 : AppColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DreamFundModal(),
    );
  }

  void _showAddSheet(BuildContext context, SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToFundSheet(goal: goal),
    );
  }

  void _showOptions(BuildContext context, SavingsGoal goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate900 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 6,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate700 : AppColors.pastelPink,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.pastelPinkDark),
              title: Text('Edit Fund', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DreamFundModal(existingGoal: goal),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: Text('Delete Fund', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Dream Fund', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                    content: Text('Are you sure you want to delete "${goal.name}"? \u{1F4A0}'),
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
                  Provider.of<AppState>(context, listen: false).deleteSavingsGoal(goal.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
