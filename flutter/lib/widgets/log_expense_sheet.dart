import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/budget_models.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';

class LogExpenseSheet extends StatefulWidget {
  final BudgetAllocation? preSelectedBudget;

  const LogExpenseSheet({super.key, this.preSelectedBudget});

  @override
  State<LogExpenseSheet> createState() => _LogExpenseSheetState();
}

class _LogExpenseSheetState extends State<LogExpenseSheet> {
  BudgetAllocation? _selectedBudget;
  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedBudget != null) {
      _selectedBudget = widget.preSelectedBudget;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _selectedSubCategory != null &&
      _amountController.text.isNotEmpty &&
      double.tryParse(_amountController.text) != null &&
      (double.tryParse(_amountController.text) ?? 0) > 0;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.pastelPink),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSave() async {
    if (!_isValid || _isSaving) return;
    setState(() => _isSaving = true);

    final appState = Provider.of<AppState>(context, listen: false);
    await appState.logExpense(
      subCategoryId: _selectedSubCategory!.id,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense logged successfully! 📝')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = Provider.of<AppState>(context);
    final budgets = appState.budgets;

    final resolvedSelectedBudget = _selectedBudget != null
        ? budgets.cast<BudgetAllocation?>().firstWhere(
            (b) => b?.id == _selectedBudget!.id,
            orElse: () => null,
          )
        : null;

    final availableCategories = resolvedSelectedBudget?.categories ?? <Category>[];
    final availableSubCategories = _selectedCategory?.subCategories ?? <SubCategory>[];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate700 : AppColors.pastelPink,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Log Expense \u{1F4DD}',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.slate700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: AppColors.pastelPinkDark),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('BUDGET', isDark),
                  const SizedBox(height: 8),
                  _buildDropdown<BudgetAllocation>(
                    value: resolvedSelectedBudget,
                    items: budgets,
                    displayName: (b) => b.name,
                    onChanged: (b) {
                      setState(() {
                        _selectedBudget = b;
                        _selectedCategory = null;
                        _selectedSubCategory = null;
                      });
                    },
                    hint: 'Select a budget profile...',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  if (_selectedBudget != null) ...[
                    _sectionLabel('CATEGORY', isDark),
                    const SizedBox(height: 8),
                    _buildDropdown<Category>(
                      value: _selectedCategory,
                      items: availableCategories,
                      displayName: (c) => c.name,
                      onChanged: (c) {
                        setState(() {
                          _selectedCategory = c;
                          _selectedSubCategory = null;
                        });
                      },
                      hint: 'Select a category...',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_selectedCategory != null) ...[
                    _sectionLabel('SUBCATEGORY', isDark),
                    const SizedBox(height: 8),
                    _buildDropdown<SubCategory>(
                      value: _selectedSubCategory,
                      items: availableSubCategories,
                      displayName: (s) => s.name,
                      onChanged: (s) {
                        setState(() => _selectedSubCategory = s);
                      },
                      hint: 'Select a subcategory...',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_selectedSubCategory != null) ...[
                    _sectionLabel('AMOUNT', isDark),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate950 : AppColors.slate50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? AppColors.slate800 : AppColors.slate150),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _selectedBudget?.currency ?? 'PHP',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.pastelPinkDark,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.slate700,
                              ),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                hintStyle: TextStyle(color: isDark ? AppColors.slate600 : AppColors.slate300),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _sectionLabel('NOTE (OPTIONAL)', isDark),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate950 : AppColors.slate50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? AppColors.slate800 : AppColors.slate150),
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.slate700,
                        ),
                        decoration: InputDecoration(
                          hintText: 'What was this for?',
                          hintStyle: TextStyle(color: isDark ? AppColors.slate600 : AppColors.slate300),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _sectionLabel('DATE', isDark),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.slate950 : AppColors.slate50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? AppColors.slate800 : AppColors.slate150),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.pastelPinkDark),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('MMM d, y').format(_selectedDate),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.slate700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ],
              ),
            ),
            if (_selectedSubCategory != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isValid && !_isSaving ? _handleSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pastelPink,
                      disabledBackgroundColor: isDark ? AppColors.slate800 : Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Log Expense \u{1F4B3}',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        color: isDark ? AppColors.slate500 : AppColors.slate400,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String Function(T) displayName,
    required void Function(T) onChanged,
    required String hint,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate950 : AppColors.slate50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.slate800 : AppColors.slate150),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.slate600 : AppColors.slate300,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                displayName(item),
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.slate700,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
          dropdownColor: isDark ? AppColors.slate900 : Colors.white,
        ),
      ),
    );
  }
}
