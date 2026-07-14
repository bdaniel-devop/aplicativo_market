import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

/// Persistência local (SharedPreferences) para tudo o que ainda não tem
/// lugar próprio no Supabase (ratings/notificações/visitas do extensionista
/// não têm tabela — mesma lógica localStorage do site) e para o idioma.
/// A sessão de autenticação já é persistida pelo próprio supabase_flutter.
class LocalStoreService {
  static const _kLanguage = 'language';
  static const _kRatings = 'ratings';
  static const _kNotifications = 'notifications';
  static const _kVisits = 'assistance_visits';

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLanguage) ?? 'pt';
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, lang);
  }

  Future<List<Rating>> getRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kRatings) ?? [];
    return raw.map((r) => Rating.fromJson(jsonDecode(r))).toList();
  }

  Future<void> addRating(Rating rating) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kRatings) ?? [];
    raw.add(jsonEncode(rating.toJson()));
    await prefs.setStringList(_kRatings, raw);
  }

  Future<List<AppNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kNotifications) ?? [];
    return raw.map((r) => AppNotification.fromJson(jsonDecode(r))).toList();
  }

  Future<void> saveNotifications(List<AppNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kNotifications,
      notifications.map((n) => jsonEncode(n.toJson())).toList(),
    );
  }

  Future<List<AssistanceVisit>> getVisits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kVisits) ?? [];
    return raw.map((r) => AssistanceVisit.fromJson(jsonDecode(r))).toList();
  }

  Future<void> addVisit(AssistanceVisit visit) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kVisits) ?? [];
    raw.add(jsonEncode(visit.toJson()));
    await prefs.setStringList(_kVisits, raw);
  }
}
