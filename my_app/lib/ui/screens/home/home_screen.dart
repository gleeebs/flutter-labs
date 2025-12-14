import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../add_task_screen.dart';
import '../statistics_screen.dart';
import '../../widgets/error_dialog.dart';
import 'home_viewmodel.dart';
import '../../../../data/repositories/advice_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    // Сначала показываем splash screen 1.5 секунды
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1500));
      setState(() {
        _showSplash = false;
      });

      // Затем инициализируем данные
      final viewModel = context.read<HomeViewModel>();
      viewModel.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    // Показываем диалог ошибки если есть
    if (viewModel.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog(context, viewModel.error!, viewModel.clearError);
      });
    }

    // Показываем splash screen первые 1.5 секунды
    if (_showSplash) {
      return const _SplashScreen();
    }

    // Показываем загрузку или основной контент
    return viewModel.isLoading
        ? const _LoadingScreen()
        : _buildHomeWithNavigation(viewModel, context);
  }

  Widget _buildHomeWithNavigation(
    HomeViewModel viewModel,
    BuildContext context,
  ) {
    return Scaffold(
      body: IndexedStack(
        index: viewModel.currentTabIndex,
        children: [
          // Вкладка 0: Главный экран с задачами
          _HomeContent(viewModel: viewModel),

          // Вкладка 1: Статистика
          StatisticsScreen(taskRepository: viewModel.taskRepository),
        ],
      ),
      floatingActionButton: viewModel.currentTabIndex == 0
          ? FloatingActionButton(
              onPressed: () => _navigateToAddTask(context, viewModel, null),
              child: const Icon(Icons.add),
              tooltip: 'Добавить задачу',
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: viewModel.currentTabIndex,
        onTap: (index) => viewModel.changeTab(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Задачи'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Статистика',
          ),
        ],
      ),
    );
  }

  void _navigateToAddTask(
    BuildContext context,
    HomeViewModel viewModel,
    String? category,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          initialCategory: category,
          onTaskAdded: (newTask) {
            viewModel.addTask(newTask);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Задача "${newTask.title}" добавлена')),
            );
          },
        ),
      ),
    );
  }
}

// Экран-заставка (первые 1.5 секунды)
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Чёрный фон
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Анимированный логотип
            SizedBox(
              width: 80,
              height: 80,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.checklist,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Экран загрузки данных (без текста)
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Анимированный индикатор загрузки
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Простая точка с анимацией (без текста)
            SizedBox(
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedDot(0),
                  _buildAnimatedDot(1),
                  _buildAnimatedDot(2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Opacity(
            opacity: value,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeViewModel viewModel;

  const _HomeContent({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Виджет совета
        _buildAdviceWidget(context),

        // Список задач
        Expanded(child: _buildTasksList(context)),
      ],
    );
  }

  Widget _buildAdviceWidget(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Совет дня',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    await viewModel.refreshAdvice();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Совет обновлён'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  tooltip: 'Обновить совет',
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showAdviceSourceInfo(context),
                  tooltip: 'Информация об источнике',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(viewModel.currentAdvice, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              'Для обновления нажмите ↻',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    final categories = ['Работа', 'Отдых', 'Обучение', 'Быт'];

    return ListView(
      children: [
        // Быстрая статистика
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Всего', viewModel.totalTasks.toString()),
                _buildStatItem(
                  'Выполнено',
                  viewModel.completedTasks.toString(),
                ),
                _buildStatItem(
                  'Прогресс',
                  '${(viewModel.completionPercentage * 100).toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
        ),

        // Список по категориям
        for (final category in categories)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpansionTile(
              leading: _getCategoryIcon(category),
              title: Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${viewModel.getTasksByCategory(category).length} задачи',
              ),
              children: [
                for (final task in viewModel.getTasksByCategory(category))
                  ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => viewModel.toggleTaskCompletion(task.id),
                    ),
                    title: Text(
                      task.title,
                      style: task.isCompleted
                          ? TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    subtitle: Text('${task.priority} приоритет'),
                    trailing: Builder(
                      builder: (trailingContext) => IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(
                          trailingContext,
                          task.id,
                          task.title,
                        ),
                        tooltip: 'Удалить задачу',
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _navigateToAddTaskFromCategory(context, category),
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить задачу'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _navigateToAddTaskFromCategory(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          initialCategory: category,
          onTaskAdded: (newTask) {
            final viewModel = Provider.of<HomeViewModel>(
              context,
              listen: false,
            );
            viewModel.addTask(newTask);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Задача "${newTask.title}" добавлена в "$category"',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String taskId,
    String taskTitle,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить задачу?'),
        content: Text(
          'Задача будет удалена из локального хранилища. "$taskTitle"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteTask(taskId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Задача удалена из хранилища')),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAdviceSourceInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Источник советов'),
        content: const Text(
          'Советы загружаются из коллекции мотивирующих цитат.\n\n'
          'При отсутствии интернета используются локальные советы.\n\n'
          'Данные кэшируются для работы в офлайн-режиме.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Icon _getCategoryIcon(String category) {
    switch (category) {
      case 'Работа':
        return const Icon(Icons.work, color: Colors.blue);
      case 'Отдых':
        return const Icon(Icons.home, color: Colors.yellow);
      case 'Обучение':
        return const Icon(Icons.person, color: Colors.green);
      case 'Быт':
        return const Icon(Icons.shopping_cart, color: Colors.red);
      default:
        return const Icon(Icons.category);
    }
  }
}
