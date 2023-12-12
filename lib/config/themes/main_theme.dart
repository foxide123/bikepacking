import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData mainTheme = ThemeData(
  //Container colors - Color(0xfffff3d1),
  //Container alternative - Color(0xffffeabb),
  //brownish - 0xFFBA704F
  //Background color - Color(0xff975a28),
  primaryColor: Color(0xFFBA704F),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xff975a28),
  ),
  textTheme: TextTheme(
    bodyLarge: GoogleFonts.aclonica(
      textStyle: TextStyle(
        fontSize: 22,
        fontStyle: FontStyle.italic,
        color: Colors.black,
        //color: Color(0xffffeabb),
      ),
    ),
    bodyMedium: GoogleFonts.aBeeZee(
      textStyle: TextStyle(
          fontSize: 16, fontStyle: FontStyle.normal, color: Colors.black),
    ),
  ),
);
