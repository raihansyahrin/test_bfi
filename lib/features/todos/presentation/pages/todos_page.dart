import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:test_bfi/features/todos/presentation/pages/search_todos_page.dart';

import 'package:test_bfi/features/todos/presentation/provider/todos_provider.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todosProvider = Provider.of<TodosProvider>(context, listen: false);
    debugPrint('Rebuild All Todos Page');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todos"),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SearchTodosPage();
                },
              ),
            ),
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.microtask(() => todosProvider.getTodos()),
        builder: (context, asyncSnapshot) {
          debugPrint('Rebuild Body Todos Page');
          if (asyncSnapshot.connectionState == ConnectionState.waiting &&
              todosProvider.todosEntity.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer<TodosProvider>(
            builder: (context, todosProvider, child) {
              debugPrint('Rebuild Consumer Todos Page');

              if (todosProvider.isInitialLoading &&
                  todosProvider.todosEntity.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (todosProvider.error.isNotEmpty) {
                return Center(child: Text("Error: ${todosProvider.error}"));
              }

              if (todosProvider.todosEntity.isEmpty) {
                return const Center(child: Text("No Todos Available"));
              }
              return SmartRefresher(
                header: WaterDropHeader(),
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: () async {
                  await todosProvider.getTodos();
                  todosProvider.refreshController.refreshCompleted();
                },
                onLoading: () async {
                  await todosProvider.loadMoreTodos();
                  todosProvider.refreshController.loadComplete();
                },
                controller: todosProvider.refreshController,
                child: ListView.builder(
                  itemCount: todosProvider.todosEntity.length,
                  itemBuilder: (context, index) {
                    final todo = todosProvider.todosEntity[index];

                    return ListTile(
                      leading: Checkbox(
                        value: todo.completed,
                        onChanged: (value) => todosProvider.patchTodoOptimistic(
                          todo.id!,
                          value ?? false,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            todosProvider.deleteTodoOptimistic(todo.id!),
                      ),
                      title: Text(todo.title!),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Consumer<TodosProvider>(
                builder: (context, provider, child) {
                  return AlertDialog(
                    title: const Text("Add Todo"),
                    content: TextField(
                      controller: provider.postTextEditingController,
                      decoration: const InputDecoration(
                        hintText: "Enter new todo",
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          provider.postTextEditingController.clear();
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (provider
                              .postTextEditingController
                              .text
                              .isNotEmpty) {
                            provider.postTextEditingController.clear();
                            if (context.mounted) Navigator.pop(context);
                            await context.read<TodosProvider>().postTodo(
                              provider.postTextEditingController.text,
                            );
                          }
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
