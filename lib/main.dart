import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_bfi/depedency_injection.dart';
import 'package:test_bfi/features/todos/presentation/pages/todos_page.dart';
import 'package:test_bfi/features/todos/presentation/provider/todos_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => sl<TodosProvider>())],
      child: const MaterialApp(home: TodosPage()),
    );
  }
}
