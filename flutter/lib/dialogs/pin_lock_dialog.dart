import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class PinLockDialog extends StatefulWidget {
  final String correctPin;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const PinLockDialog({
    super.key,
    required this.correctPin,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<PinLockDialog> createState() => _PinLockDialogState();
}

class _PinLockDialogState extends State<PinLockDialog> with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _isError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handlePress(String num) {
    if (_pin.length < 6 && !_isError) {
      setState(() {
        _pin += num;
      });

      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _handleBackspace() {
    if (_pin.isNotEmpty && !_isError) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _verifyPin() {
    if (_pin == widget.correctPin) {
      widget.onSuccess();
    } else {
      setState(() {
        _isError = true;
      });
      _shakeController.forward();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _pin = '';
            _isError = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.slate900 : Colors.white,
      child: Stack(
        children: [
          // Close button at top right
          Positioned(
            top: 60,
            right: 24,
            child: GestureDetector(
              onTap: widget.onCancel,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: AppColors.pastelPinkDark,
                ),
              ),
            ),
          ),

          // Main lock layout
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Shield Lock Icon with status colors
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isError
                          ? Colors.red.withValues(alpha: 0.1)
                          : AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: _isError ? Colors.redAccent : AppColors.pastelPinkDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Locked Budget',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.slate700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your 6-digit royal PIN ✨',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.slate500 : AppColors.slate400,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Pin Dots indicator row
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final double offset = _shakeAnimation.value;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            final bool isFilled = _pin.length > index;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isError
                                    ? Colors.redAccent
                                    : (isFilled ? AppColors.pastelPink : Colors.transparent),
                                border: Border.all(
                                  color: _isError
                                      ? Colors.redAccent
                                      : (isFilled
                                          ? AppColors.pastelPink
                                          : (isDark ? AppColors.slate700 : AppColors.slate200)),
                                  width: 2,
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 48),

                  // Keypad grid
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        String key = '';
                        Widget? keyChild;

                        if (index < 9) {
                          key = '${index + 1}';
                          keyChild = Text(
                            key,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.slate300 : AppColors.slate700,
                            ),
                          );
                        } else if (index == 9) {
                          // Empty spacer
                          return const SizedBox.shrink();
                        } else if (index == 10) {
                          key = '0';
                          keyChild = Text(
                            key,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.slate300 : AppColors.slate700,
                            ),
                          );
                        } else if (index == 11) {
                          key = 'back';
                          keyChild = Icon(
                            Icons.backspace_outlined,
                            size: 20,
                            color: AppColors.dynamicPinkDark(isDark).withValues(alpha: 0.5),
                          );
                        }

                        return GestureDetector(
                          onTap: () {
                            if (key == 'back') {
                              _handleBackspace();
                            } else if (key.isNotEmpty) {
                              _handlePress(key);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? AppColors.slate850
                                  : AppColors.pastelPinkLight.withValues(alpha: 0.25),
                            ),
                            child: Center(child: keyChild),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension helper for missing colors
extension AppColorsHelper2 on AppColors {
  static Color slate200() => const Color(0xFFE2E8F0);
}
