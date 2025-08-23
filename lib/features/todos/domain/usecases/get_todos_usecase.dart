import 'package:dartz/dartz.dart';
import 'package:test_bfi/features/todos/domain/entities/todos_entity.dart';
import 'package:test_bfi/features/todos/domain/repositories/todos_repository.dart';

class GetTodosUsecase {
  final TodosRepository todosRepository;

  GetTodosUsecase({required this.todosRepository});

  Future<Either<String, List<TodosEntity>>> call({
    required int start,
    required int limit,
    String? query,
  }) async {
    return await todosRepository.getTodos(
      start: start,
      limit: limit,
      query: query,
    );
  }
}
