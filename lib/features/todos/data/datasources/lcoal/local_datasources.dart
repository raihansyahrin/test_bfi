import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:test_bfi/features/todos/data/models/todos_model.dart';

class LocalDatasources {
  static const String todosKey = "todos";

  Future<void> saveTodos(List<TodosModel> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final String todosJson = jsonEncode(todos.map((e) => e.toJson()).toList());
    await prefs.setString(todosKey, todosJson);
  }

  Future<List<TodosModel>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString(todosKey);
    if (todosJson != null) {
      final List<dynamic> jsonList = jsonDecode(todosJson);
      return jsonList.map((e) => TodosModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> clearTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(todosKey);
  }
}
