import 'package:flutter/material.dart';

class AppColors {
  // Pastel Pink Palette
  static const Color pastelPink = Color(0xFFFFB6C1);
  static const Color pastelPinkLight = Color(0xFFFADADD);
  static const Color pastelPinkDark = Color(0xFFEC7063);
  static const Color pastelSalmon = Color(0xFFF5B7B1);
  static const Color pastelCoral = Color(0xFFF1948A);
  static const Color accent = Color(0xFFEC7063);
  static const Color backgroundSoft = Color(0xFFFFF8FA);
  
  // Neutral Colors (Matching Slate palette)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate150 = Color(0xFFE2E8F0);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate250 = Color(0xFFCBD5E1);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate450 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate550 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate750 = Color(0xFF1E293B);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate850 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);
  
  // Helpers to fetch colors dynamically based on dark mode state
  static Color surfaceColor(bool isDarkMode) =>
      isDarkMode ? slate900 : Colors.white;

  static Color borderAccent(bool isDarkMode) =>
      isDarkMode ? const Color(0x33FFB6C1) : const Color(0x1BFFB6C1); // pastel-pink/20 vs /10

  static Color dynamicPinkDark(bool isDarkMode) =>
      isDarkMode ? pastelPink : pastelPinkDark;
}
