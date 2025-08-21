import 'package:dartz/dartz.dart';
import 'package:test_bfi/features/todos/domain/entities/todos.dart';
import 'package:test_bfi/features/todos/domain/repositories/todos_repository.dart';

class GetTodosUsecase {
  final TodosRepository todosRepository;

  GetTodosUsecase({required this.todosRepository});

  Future<Either<String, List<TodosEntity>>> call() async {
    return await todosRepository.getTodos();
  }
}
