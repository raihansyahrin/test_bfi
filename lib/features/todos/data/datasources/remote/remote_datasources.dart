import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_bfi/core/const/base_url.dart';
import 'package:test_bfi/features/todos/data/models/todos_model.dart';
import 'package:test_bfi/features/todos/domain/entities/todos.dart';

abstract class RemoteDatasources {
  Future<List<TodosModel>> getTodos();
  Future<void> postTodo(String title);
  Future<TodosEntity> patchTodo(int id, bool completed);
  Future<void> deleteTodo(int id);
}

class RemoteDatasourcesImpl implements RemoteDatasources {
  final http.Client client;
  RemoteDatasourcesImpl({required this.client});

  @override
  Future<List<TodosModel>> getTodos() async {
    final response = await client.get(Uri.parse("$baseUrl/todos"));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => TodosModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load todos");
    }
  }

  @override
  Future<TodosEntity> postTodo(String title) async {
    final response = await client.post(
      Uri.parse("$baseUrl/todos"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title, "completed": false}),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return TodosModel.fromJson(json);
    } else {
      throw Exception("Failed to create todo");
    }
  }

  @override
  Future<TodosEntity> patchTodo(int id, bool completed) async {
    final response = await client.patch(
      Uri.parse("$baseUrl/todos/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"completed": completed}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return TodosModel.fromJson(json);
    } else {
      throw Exception("Failed to update todo");
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    final response = await client.delete(Uri.parse("$baseUrl/todos/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete todo");
    }
  }
}
