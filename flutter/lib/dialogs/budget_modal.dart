import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../models/budget_models.dart';
import '../theme/app_colors.dart';

class BudgetModal extends StatefulWidget {
  final BudgetAllocation? initialData;
  final Function(BudgetAllocation) onSave;
  final VoidCallback onClose;

  const BudgetModal({
    super.key,
    this.initialData,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<BudgetModal> createState() => _BudgetModalState();
}

class _BudgetModalState extends State<BudgetModal> {
  int _currentStep = 1; // 1: Details, 2: Categories, 3: PIN Lock

  // Step 1 Controllers
  final _nameController = TextEditingController();
  final _totalBudgetController = TextEditingController();
  String _selectedCurrency = 'PHP';
  int _daysToConsume = 30;

  // Step 2 categories state
  List<Category> _categories = [];

  // Step 3 PIN state
  String _pin = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final b = widget.initialData!;
      _nameController.text = b.name;
      _totalBudgetController.text = b.totalBudget.toStringAsFixed(0);
      _selectedCurrency = b.currency;
      _daysToConsume = b.daysToConsume;
      _pin = b.pin ?? '';

      // Perform deep copy of categories
      _categories = b.categories.map((c) {
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalBudgetController.dispose();
    super.dispose();
  }

  double get _totalBudget => double.tryParse(_totalBudgetController.text) ?? 0.0;

  double get _allocatedTotal =>
      _categories.fold(0.0, (sum, cat) => sum + cat.allocatedAmount);

  double get _remainingToAllocate => _totalBudget - _allocatedTotal;

  String? get _step1Error {
    if (_nameController.text.trim().isEmpty) {
      return "Please enter a profile name! ✨";
    }
    if (_totalBudget <= 0) {
      return "Total budget must be greater than zero! 🌸";
    }
    return null;
  }

  String? get _step2Error {
    if (_remainingToAllocate < 0) {
      return "Whoops! Total category allocations exceed your budget limits! 🎀";
    }
    if (_categories.any((cat) => cat.name.trim().isEmpty)) {
      return "Category names cannot be empty! ✨";
    }
    for (var cat in _categories) {
      final double subTotal =
          cat.subCategories.fold(0.0, (sum, sub) => sum + sub.allocatedAmount);
      if (subTotal > cat.allocatedAmount) {
        return "Subcategory total exceeds its category allocation limit! 🌸";
      }
    }
    return null;
  }

  String _generateRandomId() {
    return Random().nextInt(10000000).toString();
  }

  // Categories helper operations
  void _addCategory() {
    setState(() {
      _categories.add(Category(
        id: _generateRandomId(),
        budgetId: widget.initialData?.id ?? '',
        name: '',
        allocatedAmount: 0.0,
        spentAmount: 0.0,
        subCategories: [],
      ));
    });
  }

  void _removeCategory(String id) {
    setState(() {
      _categories.removeWhere((c) => c.id == id);
    });
  }

  void _updateCategoryName(String id, String name) {
    setState(() {
      final idx = _categories.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _categories[idx] = _categories[idx].copyWith(name: name);
      }
    });
  }

  void _updateCategoryAmount(String id, double amount) {
    setState(() {
      final idx = _categories.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _categories[idx] = _categories[idx].copyWith(allocatedAmount: amount);
      }
    });
  }

  void _addSubCategory(String categoryId) {
    setState(() {
      final idx = _categories.indexWhere((c) => c.id == categoryId);
      if (idx != -1) {
        final cat = _categories[idx];
        final List<SubCategory> updatedSubs = List.from(cat.subCategories);
        updatedSubs.add(SubCategory(
          id: _generateRandomId(),
          categoryId: categoryId,
          name: '',
          allocatedAmount: 0.0,
          spentAmount: 0.0,
        ));
        _categories[idx] = cat.copyWith(subCategories: updatedSubs);
      }
    });
  }

  void _removeSubCategory(String categoryId, String subId) {
    setState(() {
      final idx = _categories.indexWhere((c) => c.id == categoryId);
      if (idx != -1) {
        final cat = _categories[idx];
        final List<SubCategory> updatedSubs = List.from(cat.subCategories);
        updatedSubs.removeWhere((s) => s.id == subId);
        _categories[idx] = cat.copyWith(subCategories: updatedSubs);
      }
    });
  }

  void _updateSubCategoryName(String categoryId, String subId, String name) {
    setState(() {
      final idx = _categories.indexWhere((c) => c.id == categoryId);
      if (idx != -1) {
        final cat = _categories[idx];
        final List<SubCategory> updatedSubs = cat.subCategories.map((s) {
          return s.id == subId ? s.copyWith(name: name) : s;
        }).toList();
        _categories[idx] = cat.copyWith(subCategories: updatedSubs);
      }
    });
  }

  void _updateSubCategoryAmount(
      String categoryId, String subId, double amount) {
    setState(() {
      final idx = _categories.indexWhere((c) => c.id == categoryId);
      if (idx != -1) {
        final cat = _categories[idx];
        final List<SubCategory> updatedSubs = cat.subCategories.map((s) {
          return s.id == subId ? s.copyWith(allocatedAmount: amount) : s;
        }).toList();
        _categories[idx] = cat.copyWith(subCategories: updatedSubs);
      }
    });
  }

  // Keypad controls for PIN
  void _handlePinPress(String num) {
    if (_pin.length < 6) {
      setState(() {
        _pin += num;
      });
    }
  }

  void _handlePinBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _handleSave() {
    final budgetId = widget.initialData?.id ?? _generateRandomId();

    // Re-link Category budgetIds and SubCategory categoryIds
    final finalCategories = _categories.map((c) {
      final catId = c.id;
      final reSubCategories = c.subCategories.map((s) {
        return s.copyWith(categoryId: catId);
      }).toList();
      return c.copyWith(budgetId: budgetId, subCategories: reSubCategories);
    }).toList();

    final budget = BudgetAllocation(
      id: budgetId,
      name: _nameController.text.trim(),
      totalBudget: _totalBudget,
      currency: _selectedCurrency,
      daysToConsume: _daysToConsume,
      createdAt: widget.initialData?.createdAt ?? DateTime.now(),
      pin: _pin.isEmpty ? null : _pin,
      categories: finalCategories,
    );

    widget.onSave(budget);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.initialData != null
                          ? 'Edit Budget Profile'
                          : 'New Budget Profile',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.slate700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'STEP $_currentStep OF 3',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppColors.dynamicPinkDark(isDark),
                      ),
                    ),
                  ],
                ),
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
          ),

          // Step forms container
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
              child: Column(
                children: [
                  if (_currentStep == 1) _buildStep1(isDark),
                  if (_currentStep == 2) _buildStep2(isDark),
                  if (_currentStep == 3) _buildStep3(isDark),
                ],
              ),
            ),
          ),

          // Footer buttons navigation
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
            child: Row(
              children: [
                if (_currentStep > 1) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      child: Text(
                        'Back',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep == 1) {
                        if (_step1Error == null) {
                          setState(() {
                            _currentStep = 2;
                          });
                        }
                      } else if (_currentStep == 2) {
                        if (_step2Error == null) {
                          setState(() {
                            _currentStep = 3;
                          });
                        }
                      } else if (_currentStep == 3) {
                        _handleSave();
                      }
                    },
                    child: Text(
                      _currentStep == 3
                          ? 'Save Profile ✨'
                          : 'Continue',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
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

  // STEP 1: DETAILS
  Widget _buildStep1(bool isDark) {
    final stepErr = _step1Error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stepErr != null) ...[
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
                    stepErr,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Name Field
        Text(
          'PROFILE NAME',
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isDark ? AppColors.slate500 : AppColors.slate400,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.slate700,
          ),
          decoration: InputDecoration(
            hintText: 'e.g., Summer Travels ✈️',
            hintStyle: TextStyle(
                color: isDark ? AppColors.slate700 : AppColors.slate300),
            filled: true,
            fillColor: isDark ? AppColors.slate850 : AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.pastelPink, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Total Budget Field
        Text(
          'TOTAL BUDGET',
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isDark ? AppColors.slate500 : AppColors.slate400,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _totalBudgetController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.pastelPinkDark,
          ),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
                color: isDark ? AppColors.slate700 : AppColors.slate300),
            filled: true,
            fillColor: isDark ? AppColors.slate850 : AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.pastelPink, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Currency Grid List Selector
        Text(
          'SELECT CURRENCY',
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isDark ? AppColors.slate500 : AppColors.slate400,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['PHP', 'USD', 'EUR'].map((curr) {
            final bool isSel = _selectedCurrency == curr;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCurrency = curr;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.pastelPink
                        : (isDark ? AppColors.slate850 : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSel
                          ? AppColors.pastelPink
                          : (isDark ? AppColors.slate700 : AppColors.slate200),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      curr == 'PHP'
                          ? '₱ PHP'
                          : curr == 'USD'
                              ? '\$ USD'
                              : '€ EUR',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isSel
                            ? Colors.white
                            : (isDark ? AppColors.slate300 : AppColors.slate700),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Days to consume Slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DAYS TO CONSUME',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: isDark ? AppColors.slate500 : AppColors.slate400,
              ),
            ),
            Text(
              '$_daysToConsume DAYS',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.dynamicPinkDark(isDark),
              ),
            ),
          ],
        ),
        Slider(
          value: _daysToConsume.toDouble(),
          min: 1,
          max: 180,
          activeColor: AppColors.pastelPink,
          inactiveColor: isDark ? AppColors.slate800 : AppColors.slate200,
          onChanged: (val) {
            setState(() {
              _daysToConsume = val.round();
            });
          },
        ),
      ],
    );
  }

  // STEP 2: CATEGORIES & SUBCATEGORIES
  Widget _buildStep2(bool isDark) {
    final stepErr = _step2Error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CATEGORY ALLOCATIONS',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: isDark ? AppColors.slate500 : AppColors.slate400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Allocated: $_selectedCurrency ${_allocatedTotal.toStringAsFixed(0)} / ${_totalBudget.toStringAsFixed(0)}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.slate300 : AppColors.slate700,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _remainingToAllocate >= 0
                    ? AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5)
                    : Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _remainingToAllocate >= 0
                    ? 'Left: $_selectedCurrency ${_remainingToAllocate.toStringAsFixed(0)}'
                    : 'Over: $_selectedCurrency ${_remainingToAllocate.abs().toStringAsFixed(0)}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _remainingToAllocate >= 0
                      ? AppColors.pastelPinkDark
                      : Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (stepErr != null) ...[
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
                    stepErr,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Categories builder list
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate850 : AppColors.slate50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.slate700 : AppColors.pastelPink.withValues(alpha: 0.15),
            ),
          ),
          child: _categories.isEmpty
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
                  itemCount: _categories.length,
                  itemBuilder: (context, catIdx) {
                    final cat = _categories[catIdx];
                    final double subTotal = cat.subCategories.fold(
                        0.0, (sum, sub) => sum + sub.allocatedAmount);
                    final bool isOver = subTotal > cat.allocatedAmount;

                    return Column(
                      children: [
                        // Category row
                        Container(
                          color: isDark ? AppColors.slate900 : Colors.white,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: cat.name,
                                  onChanged: (val) =>
                                      _updateCategoryName(cat.id, val),
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.slate700,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Category Name',
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(8),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 90,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedCurrency,
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        color: isDark ? AppColors.slate500 : AppColors.slate400,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: cat.allocatedAmount > 0
                                            ? cat.allocatedAmount.toStringAsFixed(0)
                                            : '',
                                        keyboardType: TextInputType.number,
                                        onChanged: (val) =>
                                            _updateCategoryAmount(
                                                cat.id,
                                                double.tryParse(val) ?? 0.0),
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
                              IconButton(
                                onPressed: () => _removeCategory(cat.id),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Subcategories
                        ...cat.subCategories.map((sub) {
                          return Container(
                            padding: const EdgeInsets.only(
                                left: 24, right: 8, top: 4, bottom: 4),
                            color: isDark
                                ? AppColors.slate900.withValues(alpha: 0.2)
                                : AppColors.slate50.withValues(alpha: 0.5),
                            child: Row(
                              children: [
                                Container(
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: AppColors.pastelSalmon,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.only(left: 8),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: sub.name,
                                    onChanged: (val) =>
                                        _updateSubCategoryName(
                                            cat.id, sub.id, val),
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? AppColors.slate300 : AppColors.slate700,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Subcategory name',
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(6),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 70,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        _selectedCurrency,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 8,
                                          color: isDark ? AppColors.slate500 : AppColors.slate450,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: sub.allocatedAmount > 0
                                              ? sub.allocatedAmount.toStringAsFixed(0)
                                              : '',
                                          keyboardType: TextInputType.number,
                                          onChanged: (val) =>
                                              _updateSubCategoryAmount(
                                                  cat.id,
                                                  sub.id,
                                                  double.tryParse(val) ?? 0.0),
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.pastelPinkDark,
                                          ),
                                          decoration: const InputDecoration(
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
                                IconButton(
                                  onPressed: () =>
                                      _removeSubCategory(cat.id, sub.id),
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Add Subcategory button row
                        Container(
                          padding: const EdgeInsets.only(
                              left: 24, right: 16, bottom: 8, top: 4),
                          color: isDark
                              ? AppColors.slate900.withValues(alpha: 0.1)
                              : AppColors.slate50.withValues(alpha: 0.3),
                          child: Row(
                            children: [
                              Container(
                                height: 16,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: AppColors.pastelSalmon,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.only(left: 8),
                              ),
                              GestureDetector(
                                onTap: () => _addSubCategory(cat.id),
                                child: Row(
                                  children: [
                                    const Icon(Icons.add,
                                        size: 10,
                                        color: AppColors.pastelPinkDark),
                                    const SizedBox(width: 2),
                                    Text(
                                      'ADD SUBCATEGORY',
                                      style: GoogleFonts.outfit(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.pastelPinkDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (cat.allocatedAmount > 0)
                                Text(
                                  'Sub: ${subTotal.toStringAsFixed(0)} / ${cat.allocatedAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 8,
                                    color: isOver
                                        ? Colors.redAccent
                                        : (isDark ? AppColors.slate500 : AppColors.slate450),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),

        // Dashed Add Category button
        GestureDetector(
          onTap: _addCategory,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.slate700 : AppColors.pastelPink.withValues(alpha: 0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: AppColors.pastelPinkDark, size: 14),
                const SizedBox(width: 4),
                Text(
                  'ADD CATEGORY',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.pastelPinkDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // STEP 3: SECURITY PIN (OPTIONAL)
  Widget _buildStep3(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            size: 30,
            color: AppColors.pastelPinkDark,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Privacy PIN (Optional)',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.slate700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set a 6-digit privacy PIN to lock this budget plan 💅',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.slate500 : AppColors.slate400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Dots indicating PIN length
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (idx) {
            final bool isFilled = _pin.length > idx;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? AppColors.pastelPink : Colors.transparent,
                border: Border.all(
                  color: isFilled
                      ? AppColors.pastelPink
                      : (isDark ? AppColors.slate700 : AppColors.slate200),
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Numeric Keypad
        Container(
          constraints: const BoxConstraints(maxWidth: 240),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: 12,
            itemBuilder: (context, idx) {
              String val = '';
              Widget? cellChild;

              if (idx < 9) {
                val = '${idx + 1}';
                cellChild = Text(val,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.slate300 : AppColors.slate700));
              } else if (idx == 9) {
                // Clear text button
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _pin = '';
                    });
                  },
                  child: Center(
                    child: Text(
                      'Clear',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                );
              } else if (idx == 10) {
                val = '0';
                cellChild = Text(val,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.slate300 : AppColors.slate700));
              } else if (idx == 11) {
                val = 'back';
                cellChild = Icon(
                  Icons.backspace_outlined,
                  size: 16,
                  color: AppColors.dynamicPinkDark(isDark).withValues(alpha: 0.5),
                );
              }

              return GestureDetector(
                onTap: () {
                  if (val == 'back') {
                    _handlePinBackspace();
                  } else if (val.isNotEmpty) {
                    _handlePinPress(val);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.slate800
                        : AppColors.pastelPinkLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: cellChild),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
