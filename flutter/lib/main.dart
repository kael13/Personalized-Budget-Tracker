import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const BudgetarianApp(),
    ),
  );
}

class BudgetarianApp extends StatelessWidget {
  const BudgetarianApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      title: 'Bloom Budget',
      debugShowCheckedModeBanner: false,
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.backgroundSoft,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.pastelPink,
          primary: AppColors.pastelPink,
          secondary: AppColors.pastelPinkLight,
          surface: Colors.white,
          onSurface: AppColors.slate700,
          background: AppColors.backgroundSoft,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
          bodyMedium: GoogleFonts.outfit(color: AppColors.slate700, fontWeight: FontWeight.w500),
          titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.slate700),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: const BorderSide(color: Color(0x1BFFB6C1), width: 2), // border-pastel-pink/10
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.slate950,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: AppColors.pastelPink,
          primary: AppColors.pastelPink,
          secondary: AppColors.slate700,
          surface: AppColors.slate900,
          onSurface: Colors.white,
          background: AppColors.slate950,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyMedium: GoogleFonts.outfit(color: AppColors.slate300, fontWeight: FontWeight.w500),
          titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.slate900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: const BorderSide(color: Color(0x33FFB6C1), width: 2), // border-pastel-pink/20
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
