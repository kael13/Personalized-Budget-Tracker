import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      emoji: '👋',
      title: 'Uy Babe, newly installed ah!',
      subtitle: 'Your personal budget buddy is here!',
    ),
    _SlideData(
      emoji: '💖',
      title: 'I made this app for you,\nto track your budget expenses!',
      subtitle: 'Every centavo counts when we plan together.',
    ),
    _SlideData(
      emoji: '💰',
      title: 'Enge pera yaman e!\njoke hahaha!',
      subtitle: 'Let\'s start building your savings journey!',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final xFile = await _picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
    if (xFile != null && mounted) {
      await context.read<AppState>().setProfilePicture(xFile.path);
    }
  }

  void _showImagePickerSheet() {
    final appState = context.read<AppState>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate700 : AppColors.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Profile Picture',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.slate700,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.pastelPinkDark),
                title: Text('Take Photo', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.pastelPinkDark),
                title: Text('Choose from Gallery', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (appState.profilePicturePath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: Text('Remove Photo', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(ctx);
                    appState.removeProfilePicture();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _onNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onSkip() {
    _pageController.animateToPage(
      _slides.length,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onGetStarted() async {
    await context.read<AppState>().setSeenOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.slate950 : AppColors.backgroundSoft,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: mini app name banner + skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0x33FFB6C1) : const Color(0x1BFFB6C1),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌸', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          'Budgetarian',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.slate700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_currentPage < _slides.length)
                    TextButton(
                      onPressed: _onSkip,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pastelPinkDark,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 60),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  for (final slide in _slides)
                    _buildSlide(slide, isDark),
                  _buildProfileSetupPage(appState, isDark),
                ],
              ),
            ),

            // Bottom controls
            _buildBottomControls(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_SlideData slide, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.15 : 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0x33FFB6C1) : const Color(0x1BFFB6C1),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(slide.emoji, style: const TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.slate700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.slate400 : AppColors.slate500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSetupPage(AppState appState, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'One last thing! 💕',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.slate700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Set up your profile picture\nor skip for now.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.slate400 : AppColors.slate500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _showImagePickerSheet,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.pastelPinkLight.withValues(alpha: isDark ? 0.2 : 0.5),
                    border: Border.all(color: AppColors.pastelPink, width: 3),
                    image: appState.profilePicturePath != null
                        ? DecorationImage(
                            image: FileImage(File(appState.profilePicturePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: appState.profilePicturePath == null
                      ? Icon(Icons.person_outline, size: 56, color: AppColors.pastelPinkDark.withValues(alpha: 0.6))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.pastelPinkDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to set profile picture',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.slate400 : AppColors.slate500,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pastelPink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _onGetStarted,
            child: Text(
              'Skip for now',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.pastelPinkDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage < _slides.length)
            Row(
              children: List.generate(_slides.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 8),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.pastelPinkDark
                        : (isDark ? AppColors.slate700 : AppColors.slate300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            )
          else
            const Spacer(),
          if (_currentPage < _slides.length)
            GestureDetector(
              onTap: _onNext,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.pastelPinkDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SlideData {
  final String emoji;
  final String title;
  final String subtitle;

  const _SlideData({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}
