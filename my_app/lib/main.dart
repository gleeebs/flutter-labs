import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/task_repository.dart';
import 'data/repositories/advice_repository.dart';
import 'data/services/advice_service.dart';
import 'data/services/storage_service.dart';
import 'ui/screens/home/home_viewmodel.dart';
import 'ui/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Сервисы
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<AdviceService>(create: (_) => AdviceService()),

        // Репозитории
        Provider<AdviceRepository>(
          create: (context) => AdviceRepository(
            context.read<AdviceService>(),
            context.read<StorageService>(),
          ),
        ),
        Provider<TaskRepository>(
          create: (context) => TaskRepository(context.read<StorageService>()),
        ),

        // ViewModel
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(
            context.read<TaskRepository>(),
            context.read<AdviceRepository>(),
          ),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'TaskFlow',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
