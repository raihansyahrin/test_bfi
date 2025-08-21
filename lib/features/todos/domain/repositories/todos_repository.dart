import 'package:dartz/dartz.dart';
import 'package:test_bfi/features/todos/domain/entities/todos.dart';

abstract class TodosRepository {
  Future<Either<String, List<TodosEntity>>> getTodos();
  Future<Either<String, TodosEntity>> patchTodo(int id, bool completed);
  Future<Either<String, void>> postTodo(String title);
  Future<Either<String, void>> deleteTodo(int id);
}
