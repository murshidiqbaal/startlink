import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Semantic Color Palette ---
class AppColors {
  // Core Surfaces
  static const Color background = Color(
    0xFF0A0A0C,
  ); // Main background (Deep Space)
  static const Color surfaceGlass = Color(0xFF15151A); // Card background

  // Brand Gradients
  static const Color brandPurple = Color(0xFF7F56D9);
  static const Color brandCyan = Color(0xFF4FACFE);
  static const Color brandBlue = Color(0xFF42A5F5);

  // Semantic Signals
  static const Color emerald = Color(0xFF059669); // Growth/Success
  static const Color amber = Color(0xFFD97706); // Caution/Warning
  static const Color rose = Color(0xFFE11D48); // Risk/Error

  // Text
  static const Color textPrimary = Color(0xFFFFFFF2); // Soft White
  static const Color textSecondary = Color(0xFFA1A1AA); // Cool Grey

  // Gradients
  static const LinearGradient startLinkGradient = LinearGradient(
    colors: [brandPurple, brandCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x1FFFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// --- Theme Extension for Custom Colors ---
@immutable
class StartLinkColors extends ThemeExtension<StartLinkColors> {
  final LinearGradient? brandGradient;
  final LinearGradient? glassGradient;
  final Color? surfaceGlass;
  final Color? signalEmerald;
  final Color? signalAmber;
  final Color? signalRose;
  final Color? textSecondary;

  const StartLinkColors({
    required this.brandGradient,
    required this.glassGradient,
    required this.surfaceGlass,
    required this.signalEmerald,
    required this.signalAmber,
    required this.signalRose,
    required this.textSecondary,
  });

  @override
  StartLinkColors copyWith({
    LinearGradient? brandGradient,
    LinearGradient? glassGradient,
    Color? surfaceGlass,
    Color? signalEmerald,
    Color? signalAmber,
    Color? signalRose,
    Color? textSecondary,
  }) {
    return StartLinkColors(
      brandGradient: brandGradient ?? this.brandGradient,
      glassGradient: glassGradient ?? this.glassGradient,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      signalEmerald: signalEmerald ?? this.signalEmerald,
      signalAmber: signalAmber ?? this.signalAmber,
      signalRose: signalRose ?? this.signalRose,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  StartLinkColors lerp(ThemeExtension<StartLinkColors>? other, double t) {
    if (other is! StartLinkColors) return this;
    return StartLinkColors(
      brandGradient: LinearGradient.lerp(brandGradient, other.brandGradient, t),
      glassGradient: LinearGradient.lerp(glassGradient, other.glassGradient, t),
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t),
      signalEmerald: Color.lerp(signalEmerald, other.signalEmerald, t),
      signalAmber: Color.lerp(signalAmber, other.signalAmber, t),
      signalRose: Color.lerp(signalRose, other.signalRose, t),
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t),
    );
  }
}

// --- Main Theme Definition ---
class AppTheme {
  static const _baseExtension = StartLinkColors(
    brandGradient: AppColors.startLinkGradient,
    glassGradient: AppColors.glassGradient,
    surfaceGlass: AppColors.surfaceGlass,
    signalEmerald: AppColors.emerald,
    signalAmber: AppColors.amber,
    signalRose: AppColors.rose,
    textSecondary: AppColors.textSecondary,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.brandPurple,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandPurple,
        secondary: AppColors.brandCyan,
        surface: AppColors.background, // Base surface is dark
        error: AppColors.rose,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
      ),

      // Typography
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: AppColors
              .textSecondary, // Secondary text by default for bodyMedium if needed, or keep primary
          fontSize: 14,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.outfit(
          // Button text
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // Component Themes
      extensions: [_baseExtension],

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceGlass,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brandPurple),
        ),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
    );
  }
}
