import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/savings_goal_model.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';

class AddToFundSheet extends StatefulWidget {
  final SavingsGoal goal;

  const AddToFundSheet({super.key, required this.goal});

  @override
  State<AddToFundSheet> createState() => _AddToFundSheetState();
}

class _AddToFundSheetState extends State<AddToFundSheet> {
  final _amountController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _amountController.text.isNotEmpty &&
      double.tryParse(_amountController.text) != null &&
      double.parse(_amountController.text) > 0;

  Future<void> _handleAdd() async {
    if (!_isValid || _isSaving) return;
    setState(() => _isSaving = true);

    final amount = double.parse(_amountController.text);
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.addToFund(widget.goal.id, amount);

    if (mounted) {
      final isComplete = (widget.goal.savedAmount + amount) >= widget.goal.targetAmount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isComplete ? 'Dream fund complete! \u{1F31F}' : 'Added to fund! \u{1F48B}')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = widget.goal.targetAmount - widget.goal.savedAmount;
    final currency = 'PHP';

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.goal.emoji} ${widget.goal.name}',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.slate700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$currency ${widget.goal.savedAmount.toStringAsFixed(0)} / ${widget.goal.targetAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.pastelPinkDark,
                          ),
                        ),
                      ],
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
                  Text(
                    'AMOUNT TO ADD',
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: isDark ? AppColors.slate500 : AppColors.slate400,
                    ),
                  ),
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
                            currency,
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
                            autofocus: true,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.slate700,
                            ),
                            decoration: InputDecoration(
                              hintText: remaining > 0 ? '${remaining.toStringAsFixed(0)} remaining' : '0',
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
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [100, 200, 500, 1000].map((amount) {
                      return GestureDetector(
                        onTap: () {
                          _amountController.text = amount.toString();
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.pastelPink.withValues(alpha: isDark ? 0.12 : 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.pastelPink.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '$currency $amount',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.pastelPinkDark,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValid && !_isSaving ? _handleAdd : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pastelPink,
                    disabledBackgroundColor: isDark ? AppColors.slate800 : Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          'Add to Fund \u{1F48B}',
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
}
