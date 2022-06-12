import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const materialYellow50 = Color(0xFFFFFDE7);
const materialYellow100 = Color(0xFFFFF9C4);
const materialYellow200 = Color(0xFFFFF59D);
const materialYellow300 = Color(0xFFFFF176);
const materialYellow400 = Color(0xFFFFEE58);
const materialYellow500 = Color(0xFFFFEB3B);
const materialYellow600 = Color(0xFFFDD835);
const materialYellow700 = Color(0xFFFBC02D);
const materialYellow800 = Color(0xFFF9A825);
const materialYellow900 = Color(0xFFF57F17);

final textThemeLight = TextTheme(
  headline1: GoogleFonts.novaMono(color: Colors.black, fontSize: 48),
  subtitle1: GoogleFonts.novaMono(color: Colors.black, fontSize: 16),
);

final lightTheme = ThemeData(
  textTheme: textThemeLight,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: materialYellow300,
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.black
  ),
  primaryColor: materialYellow300,
  highlightColor: materialYellow100,
  scaffoldBackgroundColor: Colors.white
);

final textThemeDark = TextTheme(
  headline1: GoogleFonts.novaMono(color: Colors.white, fontSize: 48),
  subtitle1: GoogleFonts.novaMono(color: Colors.white, fontSize: 16),
);

final darkTheme = ThemeData(
    textTheme: textThemeDark,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: materialYellow500,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black
    ),
    primaryColor: materialYellow500,
    highlightColor: materialYellow700,
    scaffoldBackgroundColor: Colors.black87
);
