import 'package:dartz/dartz.dart';
import 'package:test_bfi/features/todos/domain/entities/todos_entity.dart';

abstract class TodosRepository {
  Future<Either<String, List<TodosEntity>>> getTodos({
    required int start,
    required int limit,
    String? query,
  });
  Future<Either<String, TodosEntity>> patchTodo(int id, bool completed);
  Future<Either<String, TodosEntity>> postTodo(String title);
  Future<Either<String, void>> deleteTodo(int id);
}
