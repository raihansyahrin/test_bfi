import 'package:dartz/dartz.dart';
import 'package:test_bfi/features/todos/domain/entities/todos_entity.dart';
import 'package:test_bfi/features/todos/domain/repositories/todos_repository.dart';

class PatchTodoUsecase {
  final TodosRepository todosRepository;

  PatchTodoUsecase({required this.todosRepository});

  Future<Either<String, TodosEntity>> call(int id, bool completed) async {
    return await todosRepository.patchTodo(id, completed);
  }
}
