import 'package:dartz/dartz.dart';
import 'package:test_bfi/features/todos/data/datasources/lcoal/local_datasources.dart';
import 'package:test_bfi/features/todos/data/datasources/remote/remote_datasources.dart';
import 'package:test_bfi/features/todos/data/models/todos_model.dart';
import 'package:test_bfi/features/todos/domain/entities/todos.dart';
import 'package:test_bfi/features/todos/domain/repositories/todos_repository.dart';

class TodosRepositoryImpl implements TodosRepository {
  final RemoteDatasources remoteDatasourcesImpl;
  final LocalDatasources localDatasources;

  TodosRepositoryImpl({
    required this.remoteDatasourcesImpl,
    required this.localDatasources,
  });

  @override
  Future<Either<String, List<TodosModel>>> getTodos() async {
    try {
      final response = await remoteDatasourcesImpl.getTodos();
      await localDatasources.saveTodos(response);

      return Right(response);
    } catch (e) {
      try {
        final cachedTodos = await localDatasources.loadTodos();
        return Right(cachedTodos);
      } catch (_) {
        return Left(e.toString());
      }
    }
  }

  @override
  Future<Either<String, TodosEntity>> patchTodo(int id, bool completed) async {
    try {
      final response = await remoteDatasourcesImpl.patchTodo(id, completed);
      return Right(response);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteTodo(int id) async {
    try {
      final response = await remoteDatasourcesImpl.deleteTodo(id);
      return Right(response);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> postTodo(String title) async {
    try {
      final response = await remoteDatasourcesImpl.postTodo(title);
      return Right(response);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
