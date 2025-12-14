import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _advicesKey = 'cached_advices';

  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Сохранение задач
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await _prefs;
    final tasksJson = tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_tasksKey, jsonEncode(tasksJson));
  }

  // Загрузка задач
  Future<List<Task>> loadTasks() async {
    final prefs = await _prefs;
    final tasksJson = prefs.getString(_tasksKey);

    if (tasksJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(tasksJson);
        return jsonList.map((json) => Task.fromJson(json)).toList();
      } catch (e) {
        print('Error loading tasks: $e');
      }
    }

    return []; // Возвращаем пустой список если нет сохранённых задач
  }

  // Кэширование советов
  Future<void> cacheAdvices(List<String> advices) async {
    final prefs = await _prefs;
    await prefs.setStringList(_advicesKey, advices);
  }

  // Получение кэшированных советов
  Future<List<String>> getCachedAdvices() async {
    final prefs = await _prefs;
    return prefs.getStringList(_advicesKey) ?? [];
  }

  // Очистка кэша (для тестирования)
  Future<void> clearCache() async {
    final prefs = await _prefs;
    await prefs.remove(_tasksKey);
    await prefs.remove(_advicesKey);
  }
}
