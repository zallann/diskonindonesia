  import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';

  class AppTheme {
    // Color Palette
    static const Color primaryRed = Color(0xFFDC2626);
    static const Color accentGold = Color(0xFFF59E0B);
    static const Color secondaryBlue = Color(0xFF3B82F6);
    static const Color successGreen = Color(0xFF10B981);
    static const Color warningOrange = Color(0xFFF97316);
    static const Color errorRed = Color(0xFFEF4444);
    
    static const Color neutralGray50 = Color(0xFFF9FAFB);
    static const Color neutralGray100 = Color(0xFFF3F4F6);
    static const Color neutralGray200 = Color(0xFFE5E7EB);
    static const Color neutralGray300 = Color(0xFFD1D5DB);
    static const Color neutralGray400 = Color(0xFF9CA3AF);
    static const Color neutralGray500 = Color(0xFF6B7280);
    static const Color neutralGray600 = Color(0xFF4B5563);
    static const Color neutralGray700 = Color(0xFF374151);
    static const Color neutralGray800 = Color(0xFF1F2937);
    static const Color neutralGray900 = Color(0xFF111827);

    static ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: neutralGray900,
          height: 1.2,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: neutralGray900,
          height: 1.2,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: neutralGray900,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: neutralGray900,
          height: 1.3,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: neutralGray900,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: neutralGray700,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: neutralGray700,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: neutralGray600,
          height: 1.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.white,
    shadowColor: neutralGray900.withOpacity(0.1),
  ),


      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: neutralGray900,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: neutralGray900,
        ),
      ),
      scaffoldBackgroundColor: neutralGray50,
    );

    static BoxDecoration gradientDecoration = const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryRed, accentGold],
      ),
    );

    static BoxDecoration cardDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: neutralGray900.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }