import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_bfi/core/const/base_url.dart';
import 'package:test_bfi/features/todos/data/models/todos_model.dart';

abstract class RemoteDatasources {
  Future<List<TodosModel>> getTodos({
    required int start,
    required int limit,
    String? query,
  });
  Future<TodosModel> postTodo(String title);
  Future<TodosModel> patchTodo(int id, bool completed);
  Future<void> deleteTodo(int id);
}

class RemoteDatasourcesImpl implements RemoteDatasources {
  final http.Client client;
  RemoteDatasourcesImpl({required this.client});

  @override
  Future<List<TodosModel>> getTodos({
    required int start,
    required int limit,
    String? query,
  }) async {
    final queryParams = {
      '_start': start.toString(),
      '_limit': limit.toString(),
      if (query != null && query.isNotEmpty) 'title_like': query,
    };

    final uri = Uri.https(
      'jsonplaceholder.typicode.com',
      '/todos',
      queryParams,
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TodosModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  @override
  Future<TodosModel> postTodo(String title) async {
    final response = await client.post(
      Uri.parse("$baseUrl/todos"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title, "completed": false}),
    );

    debugPrint('Status Code Post Todo: ${response.statusCode}');

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return TodosModel.fromJson(json);
    } else {
      debugPrint('error remote data post');
      throw Exception("Failed to create todo");
    }
  }

  @override
  Future<TodosModel> patchTodo(int id, bool completed) async {
    final response = await client.patch(
      Uri.parse("$baseUrl/todos/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"completed": completed}),
    );

    debugPrint('Status Code Patch Todo: ${response.statusCode}');

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
    debugPrint('Status Code Delete Todo: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception("Failed to delete todo");
    }
  }
}
