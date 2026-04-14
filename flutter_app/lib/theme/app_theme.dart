import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Main Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color backgroundOffWhite = Color(0xFFFAF9F6);
  static const Color darkText = Color(0xFF263238);
  static const Color secondaryText = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);
  
  // Role-based colors
  static const Color adminColor = Color(0xFFFFB300); // Amber 700
  static const Color producerColor = Color(0xFF2E7D32); // Green
  static const Color logisticColor = Color(0xFF1E88E5); // Blue
  static const Color buyerColor = Color(0xFF757575); // Gray

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundOffWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        background: backgroundOffWhite,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: darkText,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: darkText,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.poppins(
          color: darkText,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        bodyLarge: GoogleFonts.inter(
          color: darkText,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: secondaryText,
          fontSize: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkText),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
