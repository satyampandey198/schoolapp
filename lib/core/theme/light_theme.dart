import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

ThemeData lightTheme() {
  const primary = AppColors.primaryBlue;
  const bg = AppColors.lightBackground;
  const surface = AppColors.lightSurface;
  const surfaceVar = AppColors.lightSurfaceVariant;
  const onSurface = AppColors.lightOnSurface;
  const onSurfaceVar = AppColors.lightOnSurfaceVariant;
  const divider = AppColors.lightDivider;

  final base = ThemeData.light(useMaterial3: true);
  final textBase = GoogleFonts.interTextTheme(base.textTheme);

  return base.copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: bg,

    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: primary,
      primaryContainer: Color(0xFFDEEAFF),
      onPrimaryContainer: Color(0xFF00245C),
      secondary: AppColors.accentPurple,
      secondaryContainer: Color(0xFFEDE9FE),
      onSecondaryContainer: Color(0xFF2E1065),
      surface: surface,
      surfaceContainerHighest: surfaceVar,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVar,
      outline: divider,
      outlineVariant: Color(0xFFE8EDF5),
      shadow: Colors.black12,
      inverseSurface: Color(0xFF0F172A),
      onInverseSurface: Colors.white,
      inversePrimary: AppColors.primaryBlueLight,
    ),

    textTheme: textBase.copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w800, color: onSurface, letterSpacing: -1.2),
      displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.8),
      displaySmall: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.5),
      headlineLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: onSurface),
      headlineMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
      headlineSmall: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: onSurface),
      titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: onSurface),
      titleSmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: onSurface),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceVar),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceVar),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: onSurfaceVar),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: onSurfaceVar),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: onSurface),
      iconTheme: const IconThemeData(color: onSurface, size: 22),
      actionsIconTheme: const IconThemeData(color: onSurfaceVar, size: 22),
    ),

    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: divider, width: 1),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceVar,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: GoogleFonts.inter(color: onSurfaceVar, fontSize: 14),
      hintStyle: GoogleFonts.inter(color: onSurfaceVar.withValues(alpha: 0.6), fontSize: 14),
      errorStyle: GoogleFonts.inter(color: AppColors.error, fontSize: 12),
      prefixIconColor: onSurfaceVar,
      suffixIconColor: onSurfaceVar,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      indicatorColor: primary.withValues(alpha: 0.12),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primary, size: 22);
        }
        return IconThemeData(color: onSurfaceVar, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: primary);
        }
        return GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVar);
      }),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: surfaceVar,
      selectedColor: primary.withValues(alpha: 0.12),
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: divider),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: primary,
      unselectedLabelColor: onSurfaceVar,
      indicatorColor: primary,
      labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      dividerColor: divider,
    ),

    dividerTheme: const DividerThemeData(color: divider, thickness: 1, space: 1),

    iconTheme: const IconThemeData(color: onSurfaceVar, size: 22),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1E293B),
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return onSurfaceVar;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return divider;
      }),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: divider,
    ),
  );
}
