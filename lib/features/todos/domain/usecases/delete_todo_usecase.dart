import 'package:dartz/dartz.dart';
import 'package:test_bfi/features/todos/domain/repositories/todos_repository.dart';

class DeleteTodoUsecase {
  final TodosRepository todosRepository;

  DeleteTodoUsecase({required this.todosRepository});

  Future<Either<String, void>> call(int id) async {
    return await todosRepository.deleteTodo(id);
  }
}
