import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_state.dart';
import '../widgets/ai_recommendations.dart';
import '../theme/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  // Calculate period stats based on createdAt values
  Map<String, Map<String, dynamic>> _getPeriodStats(List<dynamic> budgets) {
    final now = DateTime.now();

    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final cleanOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final cleanOfMonth = DateTime(now.year, now.month, 1);

    final int quarterMonth = ((now.month - 1) ~/ 3) * 3 + 1;
    final cleanOfQuarter = DateTime(now.year, quarterMonth, 1);

    final cleanOfYear = DateTime(now.year, 1, 1);

    Map<String, dynamic> getStatsForPeriod(DateTime startDate) {
      final filtered = budgets.where((b) => b.createdAt.isAfter(startDate) || b.createdAt.isAtSameMomentAs(startDate));
      final double total = filtered.fold(0.0, (sum, b) => sum + b.totalBudget);
      return {'amount': total, 'count': filtered.length};
    }

    return {
      'weekly': getStatsForPeriod(cleanOfWeek),
      'monthly': getStatsForPeriod(cleanOfMonth),
      'quarterly': getStatsForPeriod(cleanOfQuarter),
      'yearly': getStatsForPeriod(cleanOfYear),
    };
  }

  // Aggregate categories across all budgets
  List<Map<String, dynamic>> _getGlobalCategoryData(List<dynamic> budgets) {
    final Map<String, double> data = {};
    for (var b in budgets) {
      for (var c in b.categories) {
        final name = c.name.trim().isEmpty ? 'Other' : c.name;
        data[name] = (data[name] ?? 0.0) + c.allocatedAmount;
      }
    }
    final List<Map<String, dynamic>> sortedList = data.entries
        .map((e) => {'name': e.key, 'value': e.value})
        .toList();
    sortedList.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final budgets = appState.budgets;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (budgets.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 80,
                color: AppColors.pastelPink.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No stats available yet ✨',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.slate500 : AppColors.slate450,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a budget plan to unlock visual analytics analytics and smart breakdowns.',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDark ? AppColors.slate600 : AppColors.slate400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final stats = _getPeriodStats(budgets);
    final categories = _getGlobalCategoryData(budgets);
    final double grandTotal = stats['yearly']!['amount'];

    // Donut chart segments helper
    final List<Color> chartColors = [
      AppColors.pastelPinkDark,
      AppColors.pastelPink,
      AppColors.pastelCoral,
      AppColors.pastelPinkLight,
      AppColors.pastelSalmon,
    ];

    List<PieChartSectionData> getSections() {
      final List<PieChartSectionData> sections = [];
      final double totalAllocatedSum = categories.fold(0.0, (sum, item) => sum + item['value']);

      for (int i = 0; i < categories.length; i++) {
        final item = categories[i];
        sections.add(PieChartSectionData(
          value: item['value'],
          color: chartColors[i % chartColors.length],
          radius: 18,
          showTitle: false,
        ));
      }

      final double remaining = grandTotal - totalAllocatedSum;
      if (remaining > 0) {
        sections.add(PieChartSectionData(
          value: remaining,
          color: isDark ? AppColors.slate800 : AppColors.slate200,
          radius: 18,
          showTitle: false,
        ));
      }
      return sections;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats summary grid card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate900 : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark ? AppColors.slate800 : AppColors.slate100,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERIOD SUMMARIES',
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: isDark ? AppColors.slate500 : AppColors.slate400,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _statsItem('This Week', stats['weekly']!['amount'], stats['weekly']!['count'], isDark),
                    _statsItem('This Month', stats['monthly']!['amount'], stats['monthly']!['count'], isDark),
                    _statsItem('This Quarter', stats['quarterly']!['amount'], stats['quarterly']!['count'], isDark),
                    _statsItem('This Year', stats['yearly']!['amount'], stats['yearly']!['count'], isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Pie chart donut layout
          if (categories.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate900 : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark ? AppColors.slate800 : AppColors.slate100,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GLOBAL ALLOCATIONS GRAPH',
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: isDark ? AppColors.slate500 : AppColors.slate400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 42,
                        sections: getSections(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Top categories progress list
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate900 : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark ? AppColors.slate800 : AppColors.slate100,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOP CATEGORIES BREAKDOWN',
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: isDark ? AppColors.slate500 : AppColors.slate400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length.clamp(0, 5),
                    itemBuilder: (context, idx) {
                      final cat = categories[idx];
                      final double val = cat['value'];
                      final double ratio = grandTotal > 0 ? (val / grandTotal) : 0.0;
                      final int pct = (ratio * 100).round();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cat['name'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.slate700,
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.slate400 : AppColors.slate700,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '₱ ${val.toStringAsFixed(0)} ',
                                        style: const TextStyle(color: AppColors.pastelPinkDark),
                                      ),
                                      TextSpan(
                                        text: '($pct%)',
                                        style: TextStyle(
                                          color: isDark ? AppColors.slate500 : AppColors.slate300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.slate950 : AppColors.slate50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: ratio.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: chartColors[idx % chartColors.length],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // AI Recommendations
          AIRecommendations(budgets: budgets),
        ],
      ),
    );
  }

  Widget _statsItem(String label, double amount, int count, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate850 : AppColors.slate50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.slate500 : AppColors.slate450,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₱ ${amount.toStringAsFixed(0)}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.slate700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '$count plans registered',
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.dynamicPinkDark(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// Ext helper for missing colors in slate palette
extension AppColorsHelper5 on AppColors {
  static Color slate600() => const Color(0xFF475569);
}
