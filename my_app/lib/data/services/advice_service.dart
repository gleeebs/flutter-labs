// lib/data/services/advice_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdviceService {
  // Используем надежный API советов - Adviceslip API
  static const String _baseUrl = 'https://api.adviceslip.com';

  // Fallback советы (используются только при полном отсутствии интернета)
  static const List<String> _fallbackAdvices = [
    'Лучший способ начать - перестать говорить и начать делать.',
    'Успех — это движение от неудачи к неудаче без потери энтузиазма.',
    'Не откладывай на завтра то, что можно сделать сегодня.',
    'Маленькие ежедневные улучшения приводят к большим результатам.',
    'Сосредоточься на процессе, а не на результате.',
  ];

  Future<String> getRandomAdvice() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/advice'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('slip')) {
          return jsonData['slip']['advice'] as String;
        }
      }

      print('API returned status ${response.statusCode}, using fallback');
      return _getRandomFallback();
    } catch (e) {
      print('Error fetching advice: $e');
      return _getRandomFallback();
    }
  }

  Future<List<String>> getMultipleAdvices() async {
    final List<String> advices = [];

    // Получаем несколько советов
    for (int i = 0; i < 3; i++) {
      try {
        final advice = await getRandomAdvice();
        if (!advices.contains(advice)) {
          advices.add(advice);
        }
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        print('Error getting advice $i: $e');
      }
    }

    if (advices.isEmpty) {
      return _fallbackAdvices.take(3).toList();
    }

    return advices;
  }

  String _getRandomFallback() {
    final randomIndex = DateTime.now().millisecond % _fallbackAdvices.length;
    return _fallbackAdvices[randomIndex];
  }
}
