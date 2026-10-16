import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/menu_suggestion.dart';
import 'ai_config.dart';
import 'ai_service.dart';
import 'gemini_client.dart';

/// การตั้งค่าของแอป (API key, โหมดสาธิต) — เก็บไว้ในเครื่องด้วย shared_preferences
///
/// เป็น ChangeNotifier: เมื่อค่าเปลี่ยน หน้าจอที่ฟังอยู่จะวาดใหม่เอง
class AppSettings extends ChangeNotifier {
  static const _keyApiKey = 'gemini_api_key';
  static const _keyDemo = 'demo_mode';
  static const _keyFavorites = 'favorite_menus';

  String _apiKey = kDevApiKey;
  bool _demoMode = false;
  bool _loaded = false;
  List<MenuSuggestion> _favorites = [];

  String get apiKey => _apiKey;
  bool get demoMode => _demoMode;
  bool get loaded => _loaded;
  bool get hasApiKey => _apiKey.trim().isNotEmpty;
  List<MenuSuggestion> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(MenuSuggestion menu) => _favorites.any((m) => m.name == menu.name);

  Future<void> toggleFavorite(MenuSuggestion menu) async {
    if (isFavorite(menu)) {
      _favorites.removeWhere((m) => m.name == menu.name);
    } else {
      _favorites.add(menu);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFavorites, jsonEncode(_favorites.map((m) => m.toJson()).toList()));
  }

  /// พร้อมใช้ AI หรือยัง (มี key หรือเปิดโหมดสาธิต)
  bool get ready => demoMode || hasApiKey;

  /// สร้าง AiService ตามการตั้งค่าปัจจุบัน
  AiService get aiService =>
      _demoMode ? DemoAiService() : GeminiAiService(GeminiClient(apiKey: _apiKey));

  /// โหลดค่าที่เคยบันทึกไว้ (เรียกครั้งเดียวตอนเปิดแอป)
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_keyApiKey) ?? kDevApiKey;
    _demoMode = prefs.getBool(_keyDemo) ?? false;
    final favJson = prefs.getString(_keyFavorites);
    if (favJson != null) {
      try {
        final list = jsonDecode(favJson) as List<dynamic>;
        _favorites = list.map((e) => MenuSuggestion.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> save({required String apiKey, required bool demoMode}) async {
    _apiKey = apiKey.trim();
    _demoMode = demoMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiKey, _apiKey);
    await prefs.setBool(_keyDemo, _demoMode);
  }
}
