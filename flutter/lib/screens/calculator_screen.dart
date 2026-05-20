import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _calcMode = 'standard'; // 'standard' or 'splitter'

  // Standard Calc State
  String _display = '';
  String _equation = '';
  bool _isDone = false;

  // Splitter State
  final _amountController = TextEditingController();
  String _splitterRatio = '50-30-20'; // '50-30-20', '70-20-10', '80-20'

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Expression Evaluator matching the React logic
  double _evaluateExpression(String expr) {
    // Sanitize and replace operator representations
    final sanitized = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll(RegExp(r'[^0-9+\-*/.]'), '');

    final List<String> tokens = [];
    String currentNum = '';

    for (int i = 0; i < sanitized.length; i++) {
      final char = sanitized[i];
      if (['+', '-', '*', '/'].contains(char)) {
        if (currentNum.isNotEmpty) {
          tokens.add(currentNum);
          currentNum = '';
        }
        // Handle negative numbers at start or after another operator
        if (char == '-' &&
            (tokens.isEmpty || ['+', '-', '*', '/'].contains(tokens.last))) {
          currentNum = '-';
        } else {
          tokens.add(char);
        }
      } else {
        currentNum += char;
      }
    }
    if (currentNum.isNotEmpty) {
      tokens.add(currentNum);
    }

    if (tokens.isEmpty) return 0.0;

    // Phase 1: Multiplication and Division
    final List<String> phase1 = [];
    int i = 0;
    while (i < tokens.length) {
      final token = tokens[i];
      if (token == '*' || token == '/') {
        final double prev = double.tryParse(phase1.isNotEmpty ? phase1.removeLast() : '0') ?? 0.0;
        final double next = double.tryParse(i + 1 < tokens.length ? tokens[i + 1] : '0') ?? 0.0;
        final double res = token == '*' ? prev * next : (next != 0 ? prev / next : 0.0);
        phase1.add(res.toString());
        i += 2;
      } else {
        phase1.add(token);
        i++;
      }
    }

    if (phase1.isEmpty) return 0.0;

    // Phase 2: Addition and Subtraction
    double result = double.tryParse(phase1[0]) ?? 0.0;
    int j = 1;
    while (j < phase1.length) {
      final op = phase1[j];
      final double val = double.tryParse(j + 1 < phase1.length ? phase1[j + 1] : '0') ?? 0.0;
      if (op == '+') {
        result += val;
      } else if (op == '-') {
        result -= val;
      }
      j += 2;
    }

    return result;
  }

  void _handleKeyPress(String val) {
    setState(() {
      if (_isDone) {
        if (['+', '-', '×', '÷'].contains(val)) {
          _display = _display + val;
          _equation = _display;
        } else {
          _display = val;
          _equation = val;
        }
        _isDone = false;
        return;
      }

      if (_display == '0' && RegExp(r'[0-9]').hasMatch(val)) {
        _display = val;
        _equation = val;
        return;
      }

      _display = _display + val;
      _equation = _equation + val;
    });
  }

  void _handleOperator(String op) {
    setState(() {
      if (_display.isEmpty && op == '-') {
        _display = '-';
        _equation = '-';
        return;
      }

      if (_display.isEmpty || ['+', '-', '×', '÷'].contains(_display.substring(_display.length - 1))) {
        return;
      }

      _display = _display + op;
      _equation = _equation + op;
      _isDone = false;
    });
  }

  void _handleClear() {
    setState(() {
      _display = '';
      _equation = '';
      _isDone = false;
    });
  }

  void _handleBackspace() {
    setState(() {
      if (_isDone) {
        _handleClear();
        return;
      }
      if (_display.isNotEmpty) {
        _display = _display.substring(0, _display.length - 1);
        _equation = _equation.substring(0, _equation.length - 1);
      }
    });
  }

  void _handleEvaluate() {
    if (_display.isEmpty) return;
    try {
      final result = _evaluateExpression(_equation);
      setState(() {
        if (result.isNaN || result.isInfinite) {
          _display = 'Error';
        } else {
          // Format output, remove trailing decimals if integer
          final rounded = double.parse(result.toStringAsFixed(4));
          if (rounded == rounded.toInt()) {
            _display = rounded.toInt().toString();
          } else {
            _display = rounded.toString();
          }
          _equation = '$_equation =';
          _isDone = true;
        }
      });
    } catch (_) {
      setState(() {
        _display = 'Error';
      });
    }
  }

  // Ratio Split Calculator results
  List<Map<String, dynamic>> _calculateSplit() {
    final double amt = double.tryParse(_amountController.text) ?? 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_splitterRatio == '50-30-20') {
      return [
        {
          'label': 'Needs (50%) 🏠',
          'amount': amt * 0.50,
          'color': isDark ? AppColors.pastelPink.withValues(alpha: 0.15) : AppColors.pastelPinkLight.withValues(alpha: 0.3),
          'textColor': AppColors.dynamicPinkDark(isDark)
        },
        {
          'label': 'Wants (30%) 🛍️',
          'amount': amt * 0.30,
          'color': AppColors.pastelSalmon.withValues(alpha: isDark ? 0.15 : 0.2),
          'textColor': AppColors.pastelCoral
        },
        {
          'label': 'Savings (20%) 🏦',
          'amount': amt * 0.20,
          'color': AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.1),
          'textColor': AppColors.accent
        }
      ];
    } else if (_splitterRatio == '70-20-10') {
      return [
        {
          'label': 'Expenses (70%) 🧾',
          'amount': amt * 0.70,
          'color': isDark ? AppColors.pastelPink.withValues(alpha: 0.15) : AppColors.pastelPinkLight.withValues(alpha: 0.3),
          'textColor': AppColors.dynamicPinkDark(isDark)
        },
        {
          'label': 'Savings (20%) 💰',
          'amount': amt * 0.20,
          'color': AppColors.pastelSalmon.withValues(alpha: isDark ? 0.15 : 0.2),
          'textColor': AppColors.pastelCoral
        },
        {
          'label': 'Fun Play (10%) 🎟️',
          'amount': amt * 0.10,
          'color': AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.1),
          'textColor': AppColors.accent
        }
      ];
    } else {
      return [
        {
          'label': 'Core Living (80%) 🔑',
          'amount': amt * 0.80,
          'color': isDark ? AppColors.pastelPink.withValues(alpha: 0.15) : AppColors.pastelPinkLight.withValues(alpha: 0.3),
          'textColor': AppColors.dynamicPinkDark(isDark)
        },
        {
          'label': 'Secure Wealth (20%) 💎',
          'amount': amt * 0.20,
          'color': AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.1),
          'textColor': AppColors.accent
        }
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Mode Selector Tab Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate900 : AppColors.slate100,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.pastelSalmon.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _calcMode = 'standard'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _calcMode == 'standard'
                            ? (isDark ? AppColors.slate700 : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: _calcMode == 'standard'
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Standard Math 🧮',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: _calcMode == 'standard'
                                ? AppColors.dynamicPinkDark(isDark)
                                : (isDark ? AppColors.slate500 : AppColors.slate450),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _calcMode = 'splitter'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _calcMode == 'splitter'
                            ? (isDark ? AppColors.slate700 : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: _calcMode == 'splitter'
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Royal Ratio Split 👑',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: _calcMode == 'splitter'
                                ? AppColors.dynamicPinkDark(isDark)
                                : (isDark ? AppColors.slate500 : AppColors.slate450),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dynamic screen loader
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _calcMode == 'standard'
                  ? _buildStandardCalculator(isDark)
                  : _buildSplitter(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // STANDARD CALCULATOR WIDGET
  Widget _buildStandardCalculator(bool isDark) {
    return Column(
      key: const ValueKey('standard'),
      children: [
        // Display Screen Panel
        Container(
          width: double.infinity,
          height: 120,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate900 : AppColors.backgroundSoft,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.pastelSalmon.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _equation.isEmpty ? '0' : _equation,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.slate500 : AppColors.slate400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _display.isEmpty ? '0' : _display,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.slate700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Grid Keypad buttons
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.25,
            children: [
              // Row 1
              _calcButton('AC',
                  color: Colors.red.withValues(alpha: 0.1),
                  textColor: Colors.redAccent,
                  onTap: _handleClear),
              _calcButton('delete',
                  color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.3),
                  textColor: AppColors.pastelPinkDark,
                  onTap: _handleBackspace,
                  isIcon: true),
              _calcButton('%',
                  color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.3),
                  textColor: AppColors.pastelPinkDark,
                  onTap: () => _handleKeyPress('%')),
              _calcButton('÷',
                  color: AppColors.pastelPink,
                  textColor: Colors.white,
                  onTap: () => _handleOperator('÷')),

              // Row 2
              _calcButton('7', isMono: true, onTap: () => _handleKeyPress('7')),
              _calcButton('8', isMono: true, onTap: () => _handleKeyPress('8')),
              _calcButton('9', isMono: true, onTap: () => _handleKeyPress('9')),
              _calcButton('×',
                  color: AppColors.pastelPink,
                  textColor: Colors.white,
                  onTap: () => _handleOperator('×')),

              // Row 3
              _calcButton('4', isMono: true, onTap: () => _handleKeyPress('4')),
              _calcButton('5', isMono: true, onTap: () => _handleKeyPress('5')),
              _calcButton('6', isMono: true, onTap: () => _handleKeyPress('6')),
              _calcButton('-',
                  color: AppColors.pastelPink,
                  textColor: Colors.white,
                  onTap: () => _handleOperator('-')),

              // Row 4
              _calcButton('1', isMono: true, onTap: () => _handleKeyPress('1')),
              _calcButton('2', isMono: true, onTap: () => _handleKeyPress('2')),
              _calcButton('3', isMono: true, onTap: () => _handleKeyPress('3')),
              _calcButton('+',
                  color: AppColors.pastelPink,
                  textColor: Colors.white,
                  onTap: () => _handleOperator('+')),

              // Row 5 (merged 0)
              _calcButton('0', isMono: true, onTap: () => _handleKeyPress('0')),
              _calcButton('.', isMono: true, onTap: () => _handleKeyPress('.')),
              // Empty spacer to occupy grid structure
              const SizedBox.shrink(),
              _calcButton('=',
                  color: AppColors.accent,
                  textColor: Colors.white,
                  onTap: _handleEvaluate),
            ],
          ),
        ),
      ],
    );
  }

  Widget _calcButton(
    String val, {
    Color? color,
    Color? textColor,
    required VoidCallback onTap,
    bool isIcon = false,
    bool isMono = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonBg = color ?? (isDark ? AppColors.slate900 : Colors.white);
    final buttonBorder = color != null
        ? Colors.transparent
        : (isDark ? AppColors.slate700 : AppColors.slate100);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: buttonBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: buttonBorder),
        ),
        child: Center(
          child: isIcon
              ? Icon(
                  Icons.backspace_outlined,
                  size: 20,
                  color: textColor ?? AppColors.pastelPinkDark,
                )
              : Text(
                  val,
                  style: isMono
                      ? GoogleFonts.jetBrainsMono(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: textColor ?? (isDark ? AppColors.slate300 : AppColors.slate700),
                        )
                      : GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: textColor ?? AppColors.pastelPinkDark,
                        ),
                ),
        ),
      ),
    );
  }

  // RATIO SPLITTER WIDGET
  Widget _buildSplitter(bool isDark) {
    final splitList = _calculateSplit();

    return Column(
      key: const ValueKey('splitter'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total budget input
        Text(
          'TOTAL BUDGET AMOUNT',
          style: GoogleFonts.outfit(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isDark ? AppColors.slate500 : AppColors.slate400,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.slate700,
          ),
          decoration: InputDecoration(
            hintText: 'e.g., 10000',
            hintStyle: TextStyle(
                color: isDark ? AppColors.slate750 : AppColors.slate300),
            prefixText: '₱ ',
            prefixStyle: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.slate500 : AppColors.slate400,
            ),
            filled: true,
            fillColor: isDark ? AppColors.slate900 : AppColors.backgroundSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.pastelPink, width: 2),
            ),
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),
        const SizedBox(height: 16),

        // Ratios standard options selectors
        Text(
          'RATIO STANDARD',
          style: GoogleFonts.outfit(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: isDark ? AppColors.slate500 : AppColors.slate400,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ratioButton('50-30-20', '50/30/20'),
            const SizedBox(width: 8),
            _ratioButton('70-20-10', '70/20/10'),
            const SizedBox(width: 8),
            _ratioButton('80-20', '80/20'),
          ],
        ),
        const SizedBox(height: 24),

        // Split lists results
        Expanded(
          child: ListView.builder(
            itemCount: splitList.length,
            itemBuilder: (context, index) {
              final item = splitList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: item['color'],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (item['textColor'] as Color).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label'],
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: item['textColor'],
                      ),
                    ),
                    Text(
                      '₱ ${item['amount'].toStringAsFixed(0)}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.slate700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Split Helper
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate900.withValues(alpha: 0.5) : AppColors.slate100.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.slate800 : AppColors.slate200,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.help_outline_rounded,
                size: 16,
                color: AppColors.pastelPinkDark,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SPLIT YOUR TOTAL SUM STANDARDLY TO BUDGET SMART AND SAFEGUARD WEALTH EFFORTLESSLY! 🌸',
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? AppColors.slate500 : AppColors.slate450,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ratioButton(String ratioVal, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSel = _splitterRatio == ratioVal;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _splitterRatio = ratioVal;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel
                ? AppColors.pastelPink
                : (isDark ? AppColors.slate900 : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSel
                  ? AppColors.pastelPink
                  : (isDark ? AppColors.slate700 : AppColors.slate200),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isSel
                    ? Colors.white
                    : (isDark ? AppColors.slate400 : AppColors.slate700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Ext helper for missing colors in slate palette
extension AppColorsHelper4 on AppColors {
  static Color slate750() => const Color(0xFF1E293B);
}
