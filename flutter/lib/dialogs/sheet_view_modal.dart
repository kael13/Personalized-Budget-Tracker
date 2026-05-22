import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/budget_models.dart';
import '../theme/app_colors.dart';

class SheetViewModal extends StatefulWidget {
  final BudgetAllocation budget;
  final Future<void> Function(BudgetAllocation) onUpdate;

  const SheetViewModal({
    super.key,
    required this.budget,
    required this.onUpdate,
  });

  @override
  State<SheetViewModal> createState() => _SheetViewModalState();
}

class _SheetViewModalState extends State<SheetViewModal> {
  late List<Category> _categories;
  late List<TextEditingController> _catNameControllers;
  late List<TextEditingController> _catAllocatedControllers;
  late List<List<TextEditingController>> _subNameControllers;
  late List<List<TextEditingController>> _subAllocatedControllers;
  late List<List<TextEditingController>> _subSpentControllers;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _categories = widget.budget.categories.map((c) => c.copyWith()).toList();
    _initControllers();
  }

  void _initControllers() {
    _catNameControllers = _categories.map((c) => TextEditingController(text: c.name)).toList();
    _catAllocatedControllers = _categories.map((c) => TextEditingController(text: c.allocatedAmount.toStringAsFixed(2))).toList();
    _subNameControllers = _categories.map((c) => c.subCategories.map((s) => TextEditingController(text: s.name)).toList()).toList();
    _subAllocatedControllers = _categories.map((c) => c.subCategories.map((s) => TextEditingController(text: s.allocatedAmount.toStringAsFixed(2))).toList()).toList();
    _subSpentControllers = _categories.map((c) => c.subCategories.map((s) => TextEditingController(text: s.spentAmount.toStringAsFixed(2))).toList()).toList();
  }

  @override
  void dispose() {
    for (final c in _catNameControllers) { c.dispose(); }
    for (final c in _catAllocatedControllers) { c.dispose(); }
    for (final subs in _subNameControllers) { for (final c in subs) { c.dispose(); } }
    for (final subs in _subAllocatedControllers) { for (final c in subs) { c.dispose(); } }
    for (final subs in _subSpentControllers) { for (final c in subs) { c.dispose(); } }
    super.dispose();
  }

  double _subSpentTotal(int catIdx) {
    return _subSpentControllers[catIdx].fold(0.0, (sum, c) => sum + (double.tryParse(c.text) ?? 0));
  }

  Future<void> _save() async {
    for (int i = 0; i < _categories.length; i++) {
      final subs = <SubCategory>[];
      for (int j = 0; j < _categories[i].subCategories.length; j++) {
        final orig = _categories[i].subCategories[j];
        subs.add(SubCategory(
          id: orig.id,
          categoryId: orig.categoryId,
          name: _subNameControllers[i][j].text,
          allocatedAmount: double.tryParse(_subAllocatedControllers[i][j].text) ?? 0,
          spentAmount: double.tryParse(_subSpentControllers[i][j].text) ?? 0,
        ));
      }
      _categories[i] = Category(
        id: _categories[i].id,
        budgetId: _categories[i].budgetId,
        name: _catNameControllers[i].text,
        allocatedAmount: double.tryParse(_catAllocatedControllers[i].text) ?? 0,
        spentAmount: _subSpentTotal(i),
        subCategories: subs,
      );
    }
    final updated = widget.budget.copyWith(categories: _categories);
    await widget.onUpdate(updated);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate900 : Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.pastelPink.withValues(alpha: isDark ? 0.12 : 0.2),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.slate700 : AppColors.pastelPink.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.table_chart_outlined,
                      color: AppColors.dynamicPinkDark(isDark), size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Sheet View',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.slate700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.budget.currency} ${widget.budget.totalBudget.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dynamicPinkDark(isDark),
                    ),
                  ),
                ],
              ),
            ),

            // Column Headers
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: isDark ? AppColors.slate850 : AppColors.slate50,
              child: Row(
                children: [
                  Expanded(flex: 3, child: _headerCell('Name', isDark)),
                  Expanded(flex: 2, child: _headerCell('Allocated', isDark, align: TextAlign.right)),
                  Expanded(flex: 2, child: _headerCell('Spent', isDark, align: TextAlign.right)),
                  SizedBox(
                    width: 48,
                    child: _headerCell('%', isDark, align: TextAlign.center),
                  ),
                ],
              ),
            ),

            // Scrollable rows
            Flexible(
              child: SingleChildScrollView(
                child: _categories.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(48),
                        child: Center(
                          child: Text(
                            'No categories added yet.',
                            style: GoogleFonts.outfit(
                              color: isDark ? AppColors.slate500 : AppColors.slate400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (int i = 0; i < _categories.length; i++) ...[
                            _buildCategoryRow(i, isDark),
                            for (int j = 0; j < _categories[i].subCategories.length; j++)
                              _buildSubCategoryRow(i, j, isDark),
                            if (i < _categories.length - 1)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: isDark ? AppColors.slate800 : AppColors.pastelPink.withValues(alpha: 0.1),
                              ),
                          ],
                        ],
                      ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.slate700 : AppColors.pastelPink.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, bool isDark, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: AppColors.dynamicPinkDark(isDark),
      ),
    );
  }

  Widget _buildCategoryRow(int i, bool isDark) {
    final catAlloc = double.tryParse(_catAllocatedControllers[i].text) ?? 0;
    final subSpent = _subSpentTotal(i);
    final pct = catAlloc > 0 ? (subSpent / catAlloc * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: isDark ? AppColors.slate900 : Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: _catNameControllers[i],
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.slate700,
              ),
              decoration: _sheetInputDecoration(isDark),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _catAllocatedControllers[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.pastelPinkDark,
              ),
              decoration: _sheetInputDecoration(isDark),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Text(
                widget.budget.currency.isNotEmpty ? '${widget.budget.currency} ${subSpent.toStringAsFixed(2)}' : subSpent.toStringAsFixed(2),
                textAlign: TextAlign.right,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.slate700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 48,
            child: Center(
              child: Text(
                '${pct.toStringAsFixed(1)}%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: pct > 100
                      ? Colors.redAccent
                      : isDark ? AppColors.slate400 : AppColors.slate500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryRow(int catIdx, int subIdx, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(left: 28, right: 12, top: 2, bottom: 2),
      color: isDark ? AppColors.slate850.withValues(alpha: 0.4) : AppColors.slate50.withValues(alpha: 0.5),
      child: Row(
        children: [
          // Connector
          Container(
            width: 16,
            height: 1,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.pastelSalmon.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: _subNameControllers[catIdx][subIdx],
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.slate300 : AppColors.slate600,
              ),
              decoration: _sheetInputDecoration(isDark),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _subAllocatedControllers[catIdx][subIdx],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.pastelCoral,
              ),
              decoration: _sheetInputDecoration(isDark),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _subSpentControllers[catIdx][subIdx],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.slate300 : AppColors.slate600,
              ),
              decoration: _sheetInputDecoration(isDark),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 52),
        ],
      ),
    );
  }

  InputDecoration _sheetInputDecoration(bool isDark) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.pastelPink.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
    );
  }
}
