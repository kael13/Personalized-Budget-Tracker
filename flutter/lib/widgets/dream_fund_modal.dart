import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/savings_goal_model.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import 'dart:math';

class DreamFundModal extends StatefulWidget {
  final SavingsGoal? existingGoal;

  const DreamFundModal({super.key, this.existingGoal});

  @override
  State<DreamFundModal> createState() => _DreamFundModalState();
}

class _DreamFundModalState extends State<DreamFundModal> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _emojiController = TextEditingController(text: '\u{1F31F}');
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      _nameController.text = widget.existingGoal!.name;
      _targetController.text = widget.existingGoal!.targetAmount.toStringAsFixed(0);
      _emojiController.text = widget.existingGoal!.emoji;
      _deadline = widget.existingGoal!.deadline;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _targetController.text.isNotEmpty &&
      double.tryParse(_targetController.text) != null &&
      double.parse(_targetController.text) > 0;

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline.isAfter(DateTime.now()) ? _deadline : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.pastelPink),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _handleSave() async {
    if (!_isValid || _isSaving) return;
    setState(() => _isSaving = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final goal = SavingsGoal(
      id: widget.existingGoal?.id ?? Random().nextInt(10000000).toString(),
      name: _nameController.text.trim(),
      targetAmount: double.parse(_targetController.text),
      savedAmount: widget.existingGoal?.savedAmount ?? 0,
      deadline: _deadline,
      emoji: _emojiController.text.trim().isNotEmpty ? _emojiController.text.trim() : '\u{1F31F}',
      createdAt: widget.existingGoal?.createdAt ?? DateTime.now(),
    );

    await appState.addSavingsGoal(goal);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.existingGoal != null ? 'Dream fund updated! \u{2728}' : 'Dream fund created! \u{1F31F}')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysLeft = _deadline.difference(DateTime.now()).inDays;

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
                    '${widget.existingGoal != null ? "Edit" : "New"} Dream Fund \u{1F31F}',
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
                  _sectionLabel('EMOJI', isDark),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate950 : AppColors.slate50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? AppColors.slate800 : AppColors.slate150),
                    ),
                    child: TextFormField(
                      controller: _emojiController,
                      style: GoogleFonts.outfit(fontSize: 24, color: isDark ? Colors.white : AppColors.slate700),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '\u{1F31F}',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _sectionLabel('FUND NAME', isDark),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.slate950 : AppColors.slate50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? AppColors.slate800 : AppColors.slate150),
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.slate700,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. Travel Fund, New Bag...',
                        hintStyle: TextStyle(color: isDark ? AppColors.slate600 : AppColors.slate300),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _sectionLabel('TARGET AMOUNT', isDark),
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
                            'PHP',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.pastelPinkDark,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _targetController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.slate700,
                            ),
                            decoration: InputDecoration(
                              hintText: '5000',
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

                  _sectionLabel('DEADLINE', isDark),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDeadline,
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
                            '$daysLeft days left \u{2022} ${_deadline.month}/${_deadline.day}/${_deadline.year}',
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
              ),
            ),
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
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          '${widget.existingGoal != null ? "Save Changes" : "Create Fund"} \u{1F48B}',
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
}
