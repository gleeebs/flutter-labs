import 'package:flutter/material.dart';
import 'package:my_app/data/repositories/task_repository.dart';

class StatisticsScreen extends StatelessWidget {
  final TaskRepository taskRepository;

  const StatisticsScreen({super.key, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    final progress = taskRepository.getCategoryProgress();

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Общая статистика
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Общая статистика',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          'Всего задач',
                          taskRepository.totalTasks.toString(),
                          Icons.list,
                        ),
                        _buildStatItem(
                          'Выполнено',
                          taskRepository.completedTasks.toString(),
                          Icons.check_circle,
                        ),
                        _buildStatItem(
                          'Процент',
                          '${(taskRepository.completionPercentage * 100).toStringAsFixed(1)}%',
                          Icons.percent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Прогресс по категориям
            const Text(
              'Прогресс по категориям',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: progress.entries.map((entry) {
                  return _buildCategoryProgress(
                    entry.key,
                    entry.value,
                    _getCategoryColor(entry.key),
                    taskRepository.getTasksByCategory(entry.key).length,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildCategoryProgress(
    String category,
    double progress,
    Color color,
    int taskCount,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getCategoryIconData(category), color: color),
                const SizedBox(width: 12),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Задач: $taskCount',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Выполнено: ${(progress * taskCount).toInt()}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Работа':
        return Colors.blue;
      case 'Отдых':
        return Colors.yellow;
      case 'Обучение':
        return Colors.green;
      case 'Быт':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIconData(String category) {
    switch (category) {
      case 'Работа':
        return Icons.work;
      case 'Отдых':
        return Icons.home;
      case 'Обучение':
        return Icons.person;
      case 'Быт':
        return Icons.shopping_cart;
      default:
        return Icons.category;
    }
  }
}
