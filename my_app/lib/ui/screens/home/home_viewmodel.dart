import 'package:flutter/material.dart';
import 'package:my_app/data/repositories/task_repository.dart';
import 'package:my_app/data/repositories/advice_repository.dart';
import 'package:my_app/domain/models/task.dart';

class HomeViewModel extends ChangeNotifier {
  // lib/ui/screens/home/home_viewmodel.dart (добавьте геттер)
  String get lastUpdateTime {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  final TaskRepository _taskRepository;
  final AdviceRepository _adviceRepository;

  bool _isLoading = true;
  String? _error;
  int _currentTabIndex = 0;

  HomeViewModel(this._taskRepository, this._adviceRepository);

  // Геттер для доступа к TaskRepository из StatisticsScreen
  TaskRepository get taskRepository => _taskRepository;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentTabIndex => _currentTabIndex;
  String get currentAdvice => _adviceRepository.currentAdvice;

  List<Task> get tasks => _taskRepository.getTasks();
  int get totalTasks => _taskRepository.totalTasks;
  int get completedTasks => _taskRepository.completedTasks;
  double get completionPercentage => _taskRepository.completionPercentage;

  // Инициализация
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.wait([
        _taskRepository.initialize(),
        _adviceRepository.initialize(),
      ]);

      _error = null;
    } catch (e) {
      _error = 'Ошибка загрузки данных: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Смена вкладки
  void changeTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // Операции с задачами
  Future<void> addTask(Task task) async {
    try {
      await _taskRepository.addTask(task);
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка добавления задачи: $e';
      notifyListeners();
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      await _taskRepository.toggleTaskCompletion(taskId);
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка обновления задачи: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskRepository.deleteTask(taskId);
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка удаления задачи: $e';
      notifyListeners();
    }
  }

  // Операции с советами
  Future<void> refreshAdvice() async {
    try {
      await _adviceRepository.refreshAdvice();
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка обновления совета: $e';
      notifyListeners();
    }
  }

  // Получение задач по категории
  List<Task> getTasksByCategory(String category) {
    return _taskRepository.getTasksByCategory(category);
  }

  // Очистка ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
