import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/budget_models.dart';
import '../services/openrouter_service.dart';
import '../theme/app_colors.dart';

class AIRecommendations extends StatefulWidget {
  final List<BudgetAllocation> budgets;

  const AIRecommendations({super.key, required this.budgets});

  @override
  State<AIRecommendations> createState() => _AIRecommendationsState();
}

class _AIRecommendationsState extends State<AIRecommendations> {
  bool _loading = false;
  String? _summary;

  @override
  void initState() {
    super.initState();
    _generateRecommendations();
  }

  @override
  void didUpdateWidget(covariant AIRecommendations oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.budgets != oldWidget.budgets) {
      _generateRecommendations();
    }
  }

  List<Map<String, dynamic>> _budgetsToJson() {
    return widget.budgets.map((b) => {
      'name': b.name,
      'totalBudget': b.totalBudget,
      'currency': b.currency,
      'daysToConsume': b.daysToConsume,
      'categories': b.categories.map((c) => {
        'name': c.name,
        'allocatedAmount': c.allocatedAmount,
        'spentAmount': c.spentAmount,
        'subCategories': c.subCategories.map((s) => {
          'name': s.name,
          'allocatedAmount': s.allocatedAmount,
          'spentAmount': s.spentAmount,
        }).toList(),
      }).toList(),
    }).toList();
  }

  List<String> _fallbackRecommendations() {
    if (widget.budgets.isEmpty) return [];

    final List<String> recs = [];
    double totalFoodAllocated = 0.0;
    double totalSavingsAllocated = 0.0;
    double grandTotalBudget = 0.0;

    for (var b in widget.budgets) {
      grandTotalBudget += b.totalBudget;
      for (var c in b.categories) {
        final name = c.name.toLowerCase();
        if (name.contains('food') || name.contains('eat') || name.contains('dining')) {
          totalFoodAllocated += c.allocatedAmount;
        }
        if (name.contains('save') || name.contains('saving') || name.contains('invest')) {
          totalSavingsAllocated += c.allocatedAmount;
        }
      }
    }

    if (grandTotalBudget > 0) {
      final double foodRatio = totalFoodAllocated / grandTotalBudget;
      final double savingsRatio = totalSavingsAllocated / grandTotalBudget;

      if (foodRatio > 0.35) {
        recs.add("Whoops! Your Food allocations look royal but heavy. Trim the feasts to save more! 🍔💅");
      }
      if (savingsRatio < 0.15) {
        recs.add("Secure your kingdom! Put a little more into Savings to guard your royal treasury. 👑🏦");
      }
    }

    final shortTerm = widget.budgets.any((b) => b.daysToConsume < 10);
    if (shortTerm) {
      recs.add("Short timeline warning! Consume your budget slowly to avoid running dry. 🌸⏳");
    }

    if (recs.isEmpty) {
      recs.add("You're budgeting like absolute royalty! Keep tracking allocations to build a rich treasury. 💎👑");
      recs.add("Consistency is key! Double check if you can split any leftover unallocated sums. 🌸🎀");
    } else if (recs.length < 3) {
      recs.add("Remember to review your subcategories. Small expenses add up quickly! ✨🛡️");
    }

    return recs;
  }

  Future<void> _generateRecommendations() async {
    if (widget.budgets.isEmpty) {
      setState(() => _summary = null);
      return;
    }

    setState(() => _loading = true);

    try {
      final content = await OpenRouterService.getRecommendations(_budgetsToJson());
      if (mounted) {
        setState(() {
          _summary = content.trim();
          _loading = false;
        });
      }
      return;
    } catch (_) {
      // API call failed — fall through to fallback
    }

    if (mounted) {
      setState(() {
        _summary = _fallbackRecommendations().join(' ');
        _loading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _generateRecommendations();
  }

  String get spanPercentFood {
    double totalFoodAllocated = 0.0;
    double grandTotalBudget = 0.0;
    for (var b in widget.budgets) {
      grandTotalBudget += b.totalBudget;
      for (var c in b.categories) {
        final name = c.name.toLowerCase();
        if (name.contains('food') || name.contains('eat') || name.contains('dining')) {
          totalFoodAllocated += c.allocatedAmount;
        }
      }
    }
    return '${(totalFoodAllocated / grandTotalBudget * 100).toStringAsFixed(0)}%';
  }

  String get spanPercentSavings {
    double totalSavingsAllocated = 0.0;
    double grandTotalBudget = 0.0;
    for (var b in widget.budgets) {
      grandTotalBudget += b.totalBudget;
      for (var c in b.categories) {
        final name = c.name.toLowerCase();
        if (name.contains('save') || name.contains('saving') || name.contains('invest')) {
          totalSavingsAllocated += c.allocatedAmount;
        }
      }
    }
    return '${(totalSavingsAllocated / grandTotalBudget * 100).toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.budgets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate900 : Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: AppColors.pastelPink.withValues(alpha: isDark ? 0.2 : 0.1),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 40,
              color: AppColors.pastelPink.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'Add some budget profiles to unlock AI royal secrets! ✨',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.slate500 : AppColors.slate400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title block
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.pastelPinkDark,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'LATEST INSIGHTS',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: AppColors.pastelPinkDark,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _loading ? null : _handleRefresh,
              child: Text(
                _loading ? 'ANALYZING...' : 'REFRESH SPARKLES ✨',
                style: GoogleFonts.outfit(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Recommendation loading overlay vs list
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _loading
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.slate900 : AppColors.backgroundSoft,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: AppColors.pastelPink.withValues(alpha: 0.2),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.pastelPinkDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AI is thinking... 💅',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: AppColors.pastelPinkDark,
                        ),
                      ),
                    ],
                  ),
                )
              : _summary != null
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate900 : AppColors.backgroundSoft,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDark ? AppColors.slate800 : AppColors.slate100,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.slate800 : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 2,
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite_border_rounded,
                              size: 16,
                              color: AppColors.pastelPinkDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _summary!,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.slate300 : AppColors.slate700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
