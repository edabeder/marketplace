import 'package:flutter/material.dart';

const Color kPink = Color(0xFFfe6796);

ThemeData buildDefaultTheme(BuildContext context) {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
    textTheme: _buildDefaultTextTheme(base.textTheme),
    primaryColor: kPink,
    colorScheme: base.colorScheme.copyWith(
      primary: kPink,
    ),
  );
}

TextTheme _buildDefaultTextTheme(TextTheme base) {
  return base.copyWith(
    titleLarge: base.titleLarge?.copyWith(fontFamily: 'Raleway'),
    headlineSmall: base.headlineSmall?.copyWith(fontFamily: 'Raleway'),
    headlineMedium: base.headlineMedium?.copyWith(fontFamily: 'Raleway'),
    displaySmall: base.displaySmall?.copyWith(fontFamily: 'Raleway'),
    displayMedium: base.displayMedium?.copyWith(fontFamily: 'Raleway'),
    displayLarge: base.displayLarge?.copyWith(fontFamily: 'Raleway'),
    titleSmall: base.titleSmall?.copyWith(fontFamily: 'Raleway'),
    titleMedium: base.titleMedium?.copyWith(fontFamily: 'Raleway'),
    bodyMedium: base.bodyMedium?.copyWith(fontFamily: 'Raleway'),
    bodyLarge: base.bodyLarge?.copyWith(fontFamily: 'Raleway'),
    bodySmall: base.bodySmall?.copyWith(fontFamily: 'Raleway'),
    labelLarge: base.labelLarge?.copyWith(fontFamily: 'Raleway'),
    labelSmall: base.labelSmall?.copyWith(fontFamily: 'Raleway'),
  );
}

const List<Color> flirtGradient = <Color>[
  Color(0xFFfe8cb3),
  Color(0xFFfe6796),
  Color(0xFFfe5464),
];
