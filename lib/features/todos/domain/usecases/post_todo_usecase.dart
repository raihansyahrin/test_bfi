import 'package:dartz/dartz.dart';
import 'package:test_bfi/features/todos/domain/repositories/todos_repository.dart';

class PostTodoUsecase {
  final TodosRepository todosRepository;

  PostTodoUsecase({required this.todosRepository});

  Future<Either<String, void>> call(String title) async {
    return await todosRepository.postTodo(title);
  }
}
