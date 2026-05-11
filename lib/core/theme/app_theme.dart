import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

//One place controls whole app UI.

class AppTheme{
  static ThemeData darkTheme = ThemeData (
    brightness: Brightness.dark,

     scaffoldBackgroundColor: AppColors.background,

    primaryColor: AppColors.primary,

    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
    ),

    cardColor: AppColors.cardColor,
  );
}