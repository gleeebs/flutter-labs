// lib/data/repositories/advice_repository.dart
import '../services/advice_service.dart';
import '../services/storage_service.dart';

class AdviceRepository {
  final AdviceService _adviceService;
  final StorageService _storageService;

  List<String> _cachedAdvices = [];
  String _currentAdvice = 'Загружаем совет...';

  // Добавляем поле для отслеживания времени
  String _lastUpdateTime = '';

  AdviceRepository(this._adviceService, this._storageService);

  Future<void> initialize() async {
    try {
      _cachedAdvices = await _storageService.getCachedAdvices();
      final freshAdvice = await _adviceService.getRandomAdvice();
      _currentAdvice = freshAdvice;
      _updateTime();

      if (!_cachedAdvices.contains(freshAdvice)) {
        _cachedAdvices.insert(0, freshAdvice);
        if (_cachedAdvices.length > 10) {
          _cachedAdvices = _cachedAdvices.sublist(0, 10);
        }
        await _storageService.cacheAdvices(_cachedAdvices);
      }
    } catch (e) {
      if (_cachedAdvices.isNotEmpty) {
        final randomIndex = DateTime.now().second % _cachedAdvices.length;
        _currentAdvice = _cachedAdvices[randomIndex];
      } else {
        _currentAdvice = await _adviceService.getRandomAdvice();
      }
      _updateTime();
    }
  }

  String get currentAdvice => _currentAdvice;
  String get lastUpdateTime => _lastUpdateTime;

  Future<void> refreshAdvice() async {
    try {
      final newAdvice = await _adviceService.getRandomAdvice();
      _currentAdvice = newAdvice;
      _updateTime();

      if (!_cachedAdvices.contains(newAdvice)) {
        _cachedAdvices.insert(0, newAdvice);
        if (_cachedAdvices.length > 10) {
          _cachedAdvices = _cachedAdvices.sublist(0, 10);
        }
        await _storageService.cacheAdvices(_cachedAdvices);
      }
    } catch (e) {
      if (_cachedAdvices.isNotEmpty) {
        final first = _cachedAdvices.removeAt(0);
        _cachedAdvices.add(first);
        _currentAdvice = _cachedAdvices.first;
      } else {
        _currentAdvice = 'Проверьте подключение к интернету';
      }
      _updateTime();
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    _lastUpdateTime =
        '${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  List<String> getAdviceHistory() => List.from(_cachedAdvices);
}
