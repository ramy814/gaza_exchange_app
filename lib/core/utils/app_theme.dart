import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ألوان حديثة ومتدرجة
  static const Color primaryColor = Color(0xFF2E7D32); // أخضر غزة
  static const Color accentColor = Color(0xFFFF6B35); // برتقالي غزة
  static const Color textColor = Color(0xFF1A1A1A); // لون النص الأساسي
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color softRed = Color(0xFFE53935);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0x1A000000);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);

  // Gradients جميلة
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [accentOrange, Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      // fontFamily: 'Cairo', // تعليق مؤقت حتى إضافة الخط
    ),
    // ... باقي الخطوط بنفس الطريقة
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      // fontFamily: 'Cairo', // تم إزالتها لأننا نستخدم GoogleFonts

      // Text Theme مع خط Cairo
      textTheme: GoogleFonts.cairoTextTheme(
        ThemeData.light().textTheme.copyWith(
              displayLarge: GoogleFonts.cairo(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              displayMedium: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              displaySmall: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              headlineLarge: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              headlineMedium: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              headlineSmall: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              titleLarge: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              titleMedium: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              titleSmall: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              bodyLarge: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: textPrimary,
              ),
              bodyMedium: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: textPrimary,
              ),
              bodySmall: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: textSecondary,
              ),
              labelLarge: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              labelMedium: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              labelSmall: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 8,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: textSecondary,
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: const Color(0xFF121212),
      brightness: Brightness.dark,
      // fontFamily: 'Cairo', // تم إزالتها لأننا نستخدم GoogleFonts
      textTheme: GoogleFonts.cairoTextTheme(
        ThemeData.dark().textTheme.copyWith(
              displayLarge: GoogleFonts.cairo(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              displayMedium: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              displaySmall: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              headlineLarge: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              headlineMedium: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              headlineSmall: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              titleLarge: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              titleMedium: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              titleSmall: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              bodyLarge: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
              bodyMedium: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
              bodySmall: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
              labelLarge: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              labelMedium: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              labelSmall: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: lightGreen,
        tertiary: accentOrange,
        surface: Color(0xFF1E1E1E),
        error: softRed,
      ),
    );
  }
}
