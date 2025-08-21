import 'package:equatable/equatable.dart';

class TodosEntity extends Equatable {
  final int userId;
  final int id;
  final String title;
  final bool completed;

  const TodosEntity({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  @override
  List<Object?> get props => [userId, id, title, completed];
}
