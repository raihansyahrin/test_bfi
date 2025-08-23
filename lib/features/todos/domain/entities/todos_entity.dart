import 'package:equatable/equatable.dart';

class TodosEntity extends Equatable {
  final int? userId;
  final int? id;
  final String? title;
  final bool? completed;

  const TodosEntity({this.userId, this.id, this.title, this.completed});

  TodosEntity copyWith({
    int? userId,
    int? id,
    String? title,
    bool? completed,
  }) => TodosEntity(
    userId: userId ?? this.userId,
    id: id ?? this.id,
    title: title ?? this.title,
    completed: completed ?? this.completed,
  );

  @override
  List<Object?> get props => [userId, id, title, completed];
}
