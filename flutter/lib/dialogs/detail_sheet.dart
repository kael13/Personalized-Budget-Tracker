import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../models/budget_models.dart';
import '../theme/app_colors.dart';
import 'sheet_view_modal.dart';

class DetailSheet extends StatefulWidget {
  final BudgetAllocation budget;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<void> Function(BudgetAllocation) onUpdate;

  const DetailSheet({
    super.key,
    required this.budget,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<DetailSheet> {
  late List<Category> _localCategories;
  final List<Color> _chartColors = [
    AppColors.pastelPinkDark,
    AppColors.pastelPink,
    AppColors.pastelCoral,
    AppColors.pastelPinkLight,
    AppColors.pastelSalmon,
  ];

  @override
  void initState() {
    super.initState();
    _initLocalCategories();
  }

  void _initLocalCategories() {
    // Perform deep copy of categories
    _localCategories = widget.budget.categories.map((c) {
      return Category(
        id: c.id,
        budgetId: c.budgetId,
        name: c.name,
        allocatedAmount: c.allocatedAmount,
        spentAmount: c.spentAmount,
        subCategories: c.subCategories.map((s) {
          return SubCategory(
            id: s.id,
            categoryId: s.categoryId,
            name: s.name,
            allocatedAmount: s.allocatedAmount,
            spentAmount: s.spentAmount,
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  void didUpdateWidget(covariant DetailSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.budget.categories != oldWidget.budget.categories) {
      setState(() {
        _initLocalCategories();
      });
    }
  }

  // Calculate totals
  double get _totalAllocated =>
      _localCategories.fold(0.0, (sum, cat) => sum + cat.allocatedAmount);

  double get _remaining => widget.budget.totalBudget - _totalAllocated;

  bool get _isDirty {
    if (_localCategories.length != widget.budget.categories.length) return true;
    for (int i = 0; i < _localCategories.length; i++) {
      final loc = _localCategories[i];
      final orig = widget.budget.categories[i];
      if (loc.id != orig.id ||
          loc.name != orig.name ||
          loc.allocatedAmount != orig.allocatedAmount) {
        return true;
      }
      if (loc.subCategories.length != orig.subCategories.length) return true;
      for (int j = 0; j < loc.subCategories.length; j++) {
        final locSub = loc.subCategories[j];
        final origSub = orig.subCategories[j];
        if (locSub.id != origSub.id ||
            locSub.name != origSub.name ||
            locSub.allocatedAmount != origSub.allocatedAmount) {
          return true;
        }
      }
    }
    return false;
  }

  // Validations
  String? get _validationError {
    if (_totalAllocated > widget.budget.totalBudget) {
      return "Oops! You've allocated more than your total budget. Adjust amounts to save! 🎀";
    }
    if (_localCategories.any((cat) => cat.name.trim().isEmpty)) {
      return "Category names cannot be empty! ✨";
    }
    if (_localCategories.any((cat) => cat.allocatedAmount < 0)) {
      return "Allocated amount cannot be negative! 💖";
    }
    for (var cat in _localCategories) {
      final double subTotal =
          cat.subCategories.fold(0.0, (sum, sub) => sum + sub.allocatedAmount);
      if (subTotal > cat.allocatedAmount) {
        return "Subcategory total exceeds its category allocated amount! 🌸";
      }
    }
    return null;
  }

  // Helper string generator
  String _generateRandomId() {
    return Random().nextInt(10000000).toString();
  }

  // Actions
  void _addCategory() {
    setState(() {
      _localCategories.add(Category(
        id: _generateRandomId(),
        budgetId: widget.budget.id,
        name: '',
        allocatedAmount: 0.0,
        spentAmount: 0.0,
        subCategories: [],
      ));
    });
  }

  void _removeCategory(String id) {
    setState(() {
      _localCategories.removeWhere((c) => c.id == id);
    });
  }

  void _updateCategoryName(String id, String name) {
    setState(() {
      final index = _localCategories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _localCategories[index] = _localCategories[index].copyWith(name: name);
      }
    });
  }

  void _updateCategoryAmount(String id, double amount) {
    setState(() {
      final index = _localCategories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _localCategories[index] =
            _localCategories[index].copyWith(allocatedAmount: amount);
      }
    });
  }

  void _addSubCategory(String categoryId) {
    setState(() {
      final index = _localCategories.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        final cat = _localCategories[index];
        final List<SubCategory> updatedSubs = List.from(cat.subCategories);
        updatedSubs.add(SubCategory(
          id: _generateRandomId(),
          categoryId: categoryId,
          name: '',
          allocatedAmount: 0.0,
          spentAmount: 0.0,
        ));
        _localCategories[index] = cat.copyWith(subCategories: updatedSubs);
      }
    });
  }

  void _removeSubCategory(String categoryId, String subId) {
    setState(() {
      final index = _localCategories.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        final cat = _localCategories[index];
        final List<SubCategory> updatedSubs = List.from(cat.subCategories);
        updatedSubs.removeWhere((s) => s.id == subId);
        _localCategories[index] = cat.copyWith(subCategories: updatedSubs);
      }
    });
  }

  void _updateSubCategoryName(String categoryId, String subId, String name) {
    setState(() {
      final index = _localCategories.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        final cat = _localCategories[index];
        final List<SubCategory> updatedSubs = cat.subCategories.map((s) {
          return s.id == subId ? s.copyWith(name: name) : s;
        }).toList();
        _localCategories[index] = cat.copyWith(subCategories: updatedSubs);
      }
    });
  }

  void _updateSubCategoryAmount(
      String categoryId, String subId, double amount) {
    setState(() {
      final index = _localCategories.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        final cat = _localCategories[index];
        final List<SubCategory> updatedSubs = cat.subCategories.map((s) {
          return s.id == subId ? s.copyWith(allocatedAmount: amount) : s;
        }).toList();
        _localCategories[index] = cat.copyWith(subCategories: updatedSubs);
      }
    });
  }

  Future<void> _handleSave() async {
    final err = _validationError;
    if (err != null) return;

    final updatedBudget = widget.budget.copyWith(categories: _localCategories);
    await widget.onUpdate(updatedBudget);
    setState(() {
      _initLocalCategories();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully! ✨')),
    );
  }

  void _handleDiscard() {
    setState(() {
      _initLocalCategories();
    });
  }

  // Construct fl_chart slices
  List<PieChartSectionData> _getChartSections(bool isDark) {
    final List<PieChartSectionData> sections = [];
    final activeCategories =
        _localCategories.where((c) => c.allocatedAmount > 0).toList();

    for (int i = 0; i < activeCategories.length; i++) {
      final cat = activeCategories[i];
      sections.add(PieChartSectionData(
        value: cat.allocatedAmount,
        color: _chartColors[i % _chartColors.length],
        radius: 20,
        showTitle: false,
      ));
    }

    if (_remaining > 0) {
      sections.add(PieChartSectionData(
        value: _remaining,
        color: isDark ? AppColors.slate700 : AppColors.slate200,
        radius: 20,
        showTitle: false,
      ));
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String currency = widget.budget.currency;
    final String? errMsg = _validationError;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle indicator
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate700 : AppColors.pastelPink,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.budget.name,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.slate700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.pastelPink.withValues(alpha: isDark ? 0.15 : 0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$currency ${widget.budget.totalBudget.toStringAsFixed(0)} TOTAL',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: AppColors.dynamicPinkDark(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.pastelPinkDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.pastelPinkDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content scroll area
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Allocated vs Remaining summary boxes
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.pastelPink.withValues(alpha: isDark ? 0.08 : 0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.pastelPink.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 14,
                                    color: AppColors.pastelPinkDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ALLOCATED',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.pastelPinkDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$currency ${_totalAllocated.toStringAsFixed(0)}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : AppColors.slate700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _remaining >= 0
                                ? (isDark ? AppColors.slate850 : AppColors.slate50)
                                : Colors.red.withValues(alpha: isDark ? 0.15 : 0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _remaining >= 0
                                  ? (isDark ? AppColors.slate700 : AppColors.slate200)
                                  : Colors.red.withValues(alpha: 0.2),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    size: 14,
                                    color: _remaining >= 0
                                        ? (isDark ? AppColors.slate550 : AppColors.slate400)
                                        : Colors.redAccent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _remaining >= 0 ? 'REMAINING' : 'OVER LIMIT',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: _remaining >= 0
                                          ? (isDark ? AppColors.slate550 : AppColors.slate400)
                                          : Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$currency ${_remaining.abs().toStringAsFixed(0)}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: _remaining >= 0
                                      ? (isDark ? Colors.white : AppColors.slate700)
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Allocation Pie Chart (fl_chart)
                  if (_localCategories.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate850 : Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isDark ? AppColors.slate700 : AppColors.slate100,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ALLOCATION GRAPH',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: isDark ? AppColors.slate500 : AppColors.slate400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 160,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 5,
                                centerSpaceRadius: 50,
                                sections: _getChartSections(isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Category Editor / Breakdown list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BREAKDOWN',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: isDark ? AppColors.slate500 : AppColors.slate400,
                        ),
                      ),
                      if (_isDirty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.pastelPink.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'UNSAVED CHANGES ✨',
                            style: GoogleFonts.outfit(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: AppColors.pastelPinkDark,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Validation Error Banner
                  if (errMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 16, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errMsg,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Table of Categories & Subcategories
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.slate900.withValues(alpha: 0.4)
                          : AppColors.slate50.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.slate700 : AppColors.pastelPink.withValues(alpha: 0.15),
                      ),
                    ),
                    child: _localCategories.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No categories added yet. 🌸',
                                style: GoogleFonts.outfit(
                                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _localCategories.length,
                            itemBuilder: (context, catIdx) {
                              final cat = _localCategories[catIdx];
                              final double subTotal = cat.subCategories.fold(
                                  0.0, (sum, sub) => sum + sub.allocatedAmount);
                              final bool isOver = subTotal > cat.allocatedAmount;

                              return Column(
                                children: [
                                  // Category row
                                  Container(
                                    color: isDark
                                        ? AppColors.slate850.withValues(alpha: 0.2)
                                        : Colors.white,
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        // Category Name input
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: cat.name,
                                            onChanged: (val) =>
                                                _updateCategoryName(cat.id, val),
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: isDark ? Colors.white : AppColors.slate700,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Category Name 🌸',
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.all(8),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                    color: AppColors.pastelCoral),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Category Amount input
                                        Container(
                                          width: 100,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Row(
                                            children: [
                                              Text(
                                                currency,
                                                style: GoogleFonts.jetBrainsMono(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Expanded(
                                                child: TextFormField(
                                                  initialValue: cat
                                                      .allocatedAmount
                                                      .toStringAsFixed(0),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onChanged: (val) =>
                                                      _updateCategoryAmount(
                                                          cat.id,
                                                          double.tryParse(val) ??
                                                              0.0),
                                                  textAlign: TextAlign.right,
                                                  style: GoogleFonts.jetBrainsMono(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900,
                                                    color: AppColors.pastelPinkDark,
                                                  ),
                                                  decoration: const InputDecoration(
                                                    hintText: '0',
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 8),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Trash delete icon
                                        IconButton(
                                          onPressed: () =>
                                              _removeCategory(cat.id),
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Subcategories rows list
                                  ...cat.subCategories.map((sub) {
                                    return Container(
                                      padding: const EdgeInsets.only(
                                          left: 24, right: 8, top: 4, bottom: 4),
                                      color: isDark
                                          ? AppColors.slate900.withValues(alpha: 0.1)
                                          : AppColors.slate50.withValues(alpha: 0.4),
                                      child: Row(
                                        children: [
                                          // Dotted connector
                                          Container(
                                            height: 36,
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                  color: AppColors.pastelSalmon,
                                                  width: 1.5,
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                            ),
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          ),
                                          // Subcategory name field
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: sub.name,
                                              onChanged: (val) =>
                                                  _updateSubCategoryName(
                                                      cat.id, sub.id, val),
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppColors.slate300 : AppColors.slate700,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Subcategory ☕',
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.all(6),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide.none,
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                      color: AppColors.pastelCoral,
                                                      width: 1.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          // Subcategory Amount input
                                          Container(
                                            width: 80,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6),
                                            child: Row(
                                              children: [
                                                Text(
                                                  currency,
                                                  style:
                                                      GoogleFonts.jetBrainsMono(
                                                    fontSize: 9,
                                                    color: isDark ? AppColors.slate500 : AppColors.slate450,
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                Expanded(
                                                  child: TextFormField(
                                                    initialValue: sub
                                                        .allocatedAmount
                                                        .toStringAsFixed(0),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (val) =>
                                                        _updateSubCategoryAmount(
                                                            cat.id,
                                                            sub.id,
                                                            double.tryParse(
                                                                    val) ??
                                                                0.0),
                                                    textAlign: TextAlign.right,
                                                    style: GoogleFonts
                                                        .jetBrainsMono(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: AppColors
                                                          .pastelPinkDark,
                                                    ),
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: '0',
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 6),
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Trash icon
                                          IconButton(
                                            onPressed: () =>
                                                _removeSubCategory(
                                                    cat.id, sub.id),
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.redAccent,
                                              size: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),

                                  // Subcategory Actions row
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 24, right: 16, bottom: 8, top: 4),
                                    color: isDark
                                        ? AppColors.slate900.withValues(alpha: 0.05)
                                        : AppColors.slate50.withValues(alpha: 0.2),
                                    child: Row(
                                      children: [
                                        // Connector line
                                        Container(
                                          height: 20,
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                color: AppColors.pastelSalmon,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                        ),
                                        // Add Subcategory Button
                                        GestureDetector(
                                          onTap: () => _addSubCategory(cat.id),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.add,
                                                  size: 11,
                                                  color:
                                                      AppColors.pastelPinkDark),
                                              const SizedBox(width: 2),
                                              Text(
                                                'ADD SUBCATEGORY',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 1.0,
                                                  color:
                                                      AppColors.pastelPinkDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        // Allocation stats
                                        if (cat.allocatedAmount > 0)
                                          Text(
                                            '$currency ${subTotal.toStringAsFixed(0)} / ${cat.allocatedAmount.toStringAsFixed(0)} Allocated',
                                            style: GoogleFonts.outfit(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w900,
                                              color: isOver
                                                  ? Colors.redAccent
                                                  : (isDark ? AppColors.slate500 : AppColors.slate450),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1, thickness: 1),
                                ],
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Dashed Add Category button
                  GestureDetector(
                    onTap: _addCategory,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? AppColors.slate700 : AppColors.pastelPink.withValues(alpha: 0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add,
                              color: AppColors.pastelPinkDark, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'ADD CATEGORY',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: AppColors.pastelPinkDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Footer bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.05 : 0.5),
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.slate800 : AppColors.slate100,
                ),
              ),
            ),
            child: _isDirty
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleDiscard,
                          child: Text(
                            'Discard',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: errMsg == null ? _handleSave : null,
                          child: Text(
                            'Save Changes ✨',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onDelete,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.pastelPink : AppColors.pastelPinkDark, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                'Delete Profile',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => SheetViewModal(
                                budget: widget.budget,
                                onUpdate: widget.onUpdate,
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.table_chart_outlined,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                'Sheet View',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// Ext helper for missing colors in slate palette
extension AppColorsHelper3 on AppColors {
  static Color slate450() => const Color(0xFF94A3B8);
  static Color slate550() => const Color(0xFF64748B);
}
