import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/qr_template.dart';

class TemplateService {
  static const String _key = 'qr_template';

  Future<void> saveTemplate(QRTemplate template) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, jsonEncode(template.toMap()));
  }

  Future<QRTemplate?> getTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return null;
    return QRTemplate.fromMap(jsonDecode(json));
  }
}
