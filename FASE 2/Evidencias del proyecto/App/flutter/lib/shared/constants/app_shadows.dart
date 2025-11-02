import "package:flutter/material.dart";

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x14352F44), blurRadius: 16, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x1F352F44), blurRadius: 24, offset: Offset(0, 18)),
    BoxShadow(color: Color(0x0F352F44), blurRadius: 8, offset: Offset(0, 4)),
  ];
}
