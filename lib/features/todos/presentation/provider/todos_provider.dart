import 'package:flutter/material.dart';
import 'package:test_bfi/features/todos/domain/entities/todos.dart';
import 'package:test_bfi/features/todos/domain/usecases/delete_todo_usecase.dart';
import 'package:test_bfi/features/todos/domain/usecases/get_todos_usecase.dart';
import 'package:test_bfi/features/todos/domain/usecases/patch_todo_usecase.dart';
import 'package:test_bfi/features/todos/domain/usecases/post_todo_usecase.dart';

class TodosProvider extends ChangeNotifier {
  final GetTodosUsecase getTodosUsecase;
  final PatchTodoUsecase patchTodoUsecase;
  final PostTodoUsecase postTodoUsecase;
  final DeleteTodoUsecase deleteTodoUsecase;

  TodosProvider(
    this.getTodosUsecase,
    this.patchTodoUsecase,
    this.postTodoUsecase,
    this.deleteTodoUsecase,
  );

  List<TodosEntity> todosEntity = [];
  List<TodosEntity> searchedTodos = [];

  String error = "";
  bool isLoading = false;
  final TextEditingController postTextEditingController =
      TextEditingController();

  /// Search todos by query (langsung dari todosEntity)
  void searchTodos(String query) {
    if (query.isEmpty) {
      searchedTodos = todosEntity;
    } else {
      searchedTodos = todosEntity
          .where(
            (todo) => todo.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  Future<List<TodosEntity>> getTodos() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await getTodosUsecase.call();
      return response.fold(
        (l) {
          error = l;
          notifyListeners();
          return [];
        },
        (r) {
          todosEntity = r;
          searchedTodos = r; // awalnya tampilkan semua

          notifyListeners();
          return r;
        },
      );
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> patchTodo(int id, bool completed) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await patchTodoUsecase.call(id, completed);
      response.fold((l) => error = l, (r) async {
        // update di list
        final index = todosEntity.indexWhere((t) => t.id == id);
        if (index != -1) {
          todosEntity[index] = r;
        }
        await getTodos();
      });
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postTodo(String title) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await postTodoUsecase.call(title);
      response.fold((l) => error = l, (r) async {
        await getTodos();
      });
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTodo(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await deleteTodoUsecase.call(id);
      response.fold((l) => error = l, (r) async {
        todosEntity.removeWhere((t) => t.id == id);
        await getTodos();
      });
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
