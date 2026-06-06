import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GeloSplashAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const GeloSplashAnimation({super.key, required this.onComplete});

  @override
  State<GeloSplashAnimation> createState() => _GeloSplashAnimationState();
}

class _GeloSplashAnimationState extends State<GeloSplashAnimation>
    with SingleTickerProviderStateMixin {
  static const _tileCount = 12;
  late final String _assetPath;
  bool _isDismissing = false;
  Timer? _dismissTimer;
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    final randomIndex = Random().nextInt(_tileCount);
    _assetPath =
        'assets/gelo/tile${randomIndex.toString().padLeft(3, '0')}.png';
    _dismissTimer = Timer(const Duration(seconds: 4), _dismiss);
    _floatController = AnimationController(
      vsync: this,
      duration: 2500.ms,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _floatController.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissing || !mounted) return;
    _dismissTimer?.cancel();
    _floatController.stop();
    setState(() => _isDismissing = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = MediaQuery.of(context).size.width * 0.25;

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 24),
        child: AnimatedOpacity(
          opacity: _isDismissing ? 0.0 : 1.0,
          duration: 400.ms,
          child: AnimatedScale(
            scale: _isDismissing ? 0.8 : 1.0,
            duration: 400.ms,
            child: GestureDetector(
              onTap: _dismiss,
              onPanUpdate: (details) {
                setState(() => _dragOffset += details.delta);
              },
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _dragOffset.dx,
                      _dragOffset.dy + _floatAnimation.value,
                    ),
                    child: child,
                  );
                },
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.06),
                        blurRadius: 48,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      _assetPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ).animate().fadeIn(
                      duration: 1000.ms,
                      curve: Curves.easeOut,
                    ).scaleXY(
                      begin: 0.85,
                      end: 1.0,
                      duration: 1000.ms,
                      curve: Curves.easeOut,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
