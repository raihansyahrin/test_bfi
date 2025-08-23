import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:test_bfi/features/todos/domain/entities/todos_entity.dart';
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

  bool isInitialLoading = false;
  bool isMoreLoading = false;
  bool isActionLoading = false;

  final TextEditingController postTextEditingController =
      TextEditingController();
  final RefreshController refreshController = RefreshController();

  int _start = 0;
  final int _limit = 20;

  void searchTodos(String query) {
    if (query.isEmpty) {
      searchedTodos = todosEntity;
    } else {
      searchedTodos = todosEntity
          .where(
            (todo) => todo.title!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  Timer? _debounce;
  List<String> recentSearches = [];
  String lastQuery = "";

  void searchTodosDebounced(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      lastQuery = query;
      if (query.isNotEmpty) {
        recentSearches.insert(0, query);
        if (recentSearches.length > 5) recentSearches.removeLast();
      }
      searchTodos(query);
    });
  }

  void clearSearch() {
    lastQuery = "";
    searchedTodos = [];
    notifyListeners();
  }

  Future<void> searchTodosFromApi(String query, {bool reset = true}) async {
    if (reset) {
      _start = 0;
      searchedTodos = [];
    }

    isInitialLoading = reset;
    isMoreLoading = !reset;

    notifyListeners();

    try {
      final response = await getTodosUsecase.call(
        start: _start,
        limit: _limit,
        query: query, // tambahin query title_like di usecase / repo
      );

      response.fold(
        (l) {
          error = l;
          notifyListeners();
        },
        (r) {
          if (reset) {
            searchedTodos = r;
          } else {
            searchedTodos.addAll(r);
          }
          _start += _limit;
          notifyListeners();
        },
      );
    } catch (e) {
      error = e.toString();
      notifyListeners();
    } finally {
      isInitialLoading = false;
      isMoreLoading = false;
      notifyListeners();
    }
  }

  Future<List<TodosEntity>> getTodos() async {
    isInitialLoading = true;
    _start = 0;

    notifyListeners();
    try {
      final response = await getTodosUsecase.call(start: _start, limit: _limit);
      return response.fold(
        (l) {
          error = l;
          notifyListeners();
          return [];
        },
        (r) {
          todosEntity = r;
          // searchedTodos = r;
          _start += _limit;

          notifyListeners();
          return r;
        },
      );
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return [];
    } finally {
      isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreTodos() async {
    if (isMoreLoading) return;

    isMoreLoading = true;
    notifyListeners();

    try {
      final response = await getTodosUsecase.call(start: _start, limit: _limit);
      response.fold(
        (l) {
          error = l;
          notifyListeners();
        },
        (r) {
          if (r.isEmpty) {
            return;
          }
          todosEntity.addAll(r);
          searchedTodos = todosEntity;
          _start += _limit;

          notifyListeners();
        },
      );
    } catch (e) {
      error = e.toString();
      notifyListeners();
    } finally {
      isMoreLoading = false;
      notifyListeners();
    }
  }

  Future<void> postTodo(String title) async {
    isActionLoading = true;
    notifyListeners();
    try {
      final response = await postTodoUsecase.call(title);
      response.fold((l) => error = l, (r) async {
        await getTodos();
      });
    } catch (e) {
      debugPrint('error post todo provider');
      error = e.toString();
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> patchTodoOptimistic(int id, bool completed) async {
    final index = todosEntity.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final oldTodo = todosEntity[index];

    todosEntity[index] = oldTodo.copyWith(completed: completed);
    notifyListeners();

    final response = await patchTodoUsecase.call(id, completed);
    response.fold(
      (l) {
        todosEntity[index] = oldTodo;
        error = l;
        notifyListeners();
      },
      (r) {
        todosEntity[index] = r;
        notifyListeners();
      },
    );
  }

  Future<void> deleteTodoOptimistic(int id) async {
    final index = todosEntity.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final oldTodo = todosEntity[index];

    todosEntity.removeAt(index);
    notifyListeners();

    final response = await deleteTodoUsecase.call(id);
    response.fold((l) {
      todosEntity.insert(index, oldTodo);
      error = l;
      notifyListeners();
    }, (r) {});
  }
}
