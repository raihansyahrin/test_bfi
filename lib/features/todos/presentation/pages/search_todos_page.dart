import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_bfi/features/todos/presentation/provider/todos_provider.dart';

class SearchTodosPage extends StatelessWidget {
  const SearchTodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TodosProvider>();
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Search Todos")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                provider.searchTodos(value);
              },
              decoration: const InputDecoration(
                hintText: "Search todo...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Consumer<TodosProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.searchedTodos.isEmpty) {
                  return const Center(child: Text("No results found"));
                }

                return ListView.builder(
                  itemCount: provider.searchedTodos.length,
                  itemBuilder: (context, index) {
                    final todo = provider.searchedTodos[index];
                    return ListTile(
                      leading: Checkbox(
                        value: todo.completed,
                        onChanged: (value) async {
                          await provider.patchTodo(todo.id, value ?? false);
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await provider.deleteTodo(todo.id);
                        },
                      ),
                      title: Text(todo.title),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
