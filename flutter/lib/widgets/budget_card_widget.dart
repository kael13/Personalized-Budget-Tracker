import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/budget_models.dart';
import '../theme/app_colors.dart';

class BudgetCardWidget extends StatelessWidget {
  final BudgetAllocation allocation;
  final VoidCallback onClick;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final VoidCallback? onDelete;

  const BudgetCardWidget({
    super.key,
    required this.allocation,
    required this.onClick,
    this.isSelected = false,
    this.onToggleSelect,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate progress
    final double totalAllocated = allocation.categories
        .fold(0.0, (sum, cat) => sum + cat.allocatedAmount);
    final double progress = allocation.totalBudget > 0
        ? (totalAllocated / allocation.totalBudget)
        : 0.0;
    final int progressPercent = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isSelected
              ? AppColors.pastelPink
              : (isDark ? const Color(0x33FFB6C1) : const Color(0x1BFFB6C1)),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.pastelPink.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: isSelected ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Decorative background circle in top-right corner
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.pastelPink.withValues(alpha: isDark ? 0.08 : 0.22),
                ),
              ),
            ),
            // Card body
            InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: onClick,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // Checkbox on Left for Edit Mode
                    if (onToggleSelect != null) ...[
                      GestureDetector(
                        onTap: onToggleSelect,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.pastelPink
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.pastelPink
                                  : (isDark ? AppColors.slate700 : AppColors.slate250),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],

                    // Main Info Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + Header icons row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      allocation.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : AppColors.slate700,
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 11,
                                          color: AppColors.dynamicPinkDark(isDark),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${allocation.daysToConsume} DAYS LEFT',
                                          style: GoogleFonts.outfit(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                            color: AppColors.dynamicPinkDark(isDark),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Pin / Action Row
                              Row(
                                children: [
                                  if (allocation.pin != null && allocation.pin!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.pastelPink.withValues(alpha: isDark ? 0.15 : 0.35),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Transform.rotate(
                                        angle: 0.78, // ~45 deg
                                        child: Icon(
                                          Icons.push_pin,
                                          size: 11,
                                          color: AppColors.dynamicPinkDark(isDark),
                                        ),
                                      ),
                                    ),
                                  if (onDelete != null) ...[
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: onDelete,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 12,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Progress values
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BUDGET PROGRESS',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? AppColors.slate500 : AppColors.slate400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? AppColors.slate300 : AppColors.slate700,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '${allocation.currency} ${totalAllocated.toStringAsFixed(0)} ',
                                          style: TextStyle(
                                            color: AppColors.dynamicPinkDark(isDark),
                                          ),
                                        ),
                                        TextSpan(
                                          text: '/ ${allocation.totalBudget.toStringAsFixed(0)}',
                                          style: GoogleFonts.outfit(
                                            color: isDark ? AppColors.slate500 : AppColors.slate300,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: progress > 0.9
                                      ? Colors.red.withValues(alpha: isDark ? 0.15 : 0.08)
                                      : AppColors.pastelPink.withValues(alpha: isDark ? 0.15 : 0.35),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$progressPercent%',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: progress > 0.9
                                        ? Colors.redAccent
                                        : AppColors.dynamicPinkDark(isDark),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Progress bar track
                          Container(
                            width: double.infinity,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.slate950 : AppColors.slate50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.pastelPink.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: progress > 1.0
                                        ? Colors.redAccent
                                        : AppColors.pastelPink,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
