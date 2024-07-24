import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color userPrimaryColor = Color(0xFF00329F);
  static const Color userPrimaryLightColor = Color(0xFFD1D1F4);
  static const Color userPrimaryButtonColor = Color(0xFF11359A);
  static const Color primaryDarkColor = Color(0xFF000066);

  // Secondary colors
  static const Color AdminThemePrimary = Color(0xFF79193E);
  static const Color AdminThemeLightPrimary = Color(0xFF706A6A);
  static const Color AdminThemeBackColor = Color(0xFFE8CED4);

  static const Color HrThemeLightColor = Color(0xFF791965);

  static const Color complementaryColor = Color(0xFF197946); // Complementary color
  static const Color analogousColor1 = Color(0xFF791946); // Analogous color 1
  static const Color analogousColor2 = Color(0xFF791965); // Analogous color 2
  static const Color triadicColor1 = Color(0xFF197946); // Triadic color 1
  static const Color triadicColor2 = Color(0xFF461979); // Triadic color 2


  // Text colors
  static const Color primaryTextColor = Color(0xFF000000);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color errorTextColor = Color(0xFFB00020);

  // Background colors
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFAFAFA);

  // Button colors
  static const Color buttonColor = Color(0xFF6200EE);
  static const Color buttonTextColor = Color(0xFFFFFFFF);

  // Other colors
  static const Color borderColor = Color(0xFFBDBDBD);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6200EE), Color(0xFF3700B3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

// Add more colors as needed
}
