import 'package:test_bfi/features/todos/domain/entities/todos.dart';

class TodosModel extends TodosEntity {
  const TodosModel({
    required super.userId,
    required super.id,
    required super.title,
    required super.completed,
  });
  TodosModel copyWith({int? userId, int? id, String? title, bool? completed}) =>
      TodosModel(
        userId: userId ?? this.userId,
        id: id ?? this.id,
        title: title ?? this.title,
        completed: completed ?? this.completed,
      );

  factory TodosModel.fromJson(Map<String, dynamic> json) => TodosModel(
    userId: json["userId"],
    id: json["id"],
    title: json["title"],
    completed: json["completed"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "id": id,
    "title": title,
    "completed": completed,
  };
}
