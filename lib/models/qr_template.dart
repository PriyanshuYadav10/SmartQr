import 'package:flutter/material.dart';

class QRTemplate {
  final Color foregroundColor;
  final Color backgroundColor;
  final String? logoPath;

  QRTemplate({
    required this.foregroundColor,
    required this.backgroundColor,
    this.logoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'fg': foregroundColor.value,
      'bg': backgroundColor.value,
      'logo': logoPath,
    };
  }

  factory QRTemplate.fromMap(Map<String, dynamic> map) {
    return QRTemplate(
      foregroundColor: Color(map['fg']),
      backgroundColor: Color(map['bg']),
      logoPath: map['logo'],
    );
  }
}
