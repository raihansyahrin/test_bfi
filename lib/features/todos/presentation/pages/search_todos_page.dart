import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_bfi/features/todos/presentation/provider/todos_provider.dart';

class SearchTodosPage extends StatelessWidget {
  const SearchTodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TodosProvider>();

    return PopScope(
      canPop: true, // biar tetep bisa back
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<TodosProvider>().clearSearch();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            decoration: const InputDecoration(
              hintText: "Search todos...",
              border: InputBorder.none,
            ),
            onChanged: (query) {
              debugPrint('query is empty ${query.length}');
              if (query.isEmpty) {
                provider.clearSearch(); // <-- tambahin method ini di provider
              } else {
                provider.searchTodosDebounced(query);
              }
            },
          ),
        ),
        body: Consumer<TodosProvider>(
          builder: (context, provider, child) {
            // kondisi awal (belum search)
            if (provider.searchedTodos.isEmpty &&
                provider.lastQuery.isEmpty &&
                !provider.isInitialLoading) {
              return _buildSuggestions(provider);
            }

            if (provider.isInitialLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error.isNotEmpty) {
              return Center(child: Text("Error: ${provider.error}"));
            }

            if (provider.searchedTodos.isEmpty) {
              return Center(
                child: Text("No results for '${provider.lastQuery}'"),
              );
            }

            // tampilkan hasil search
            return ListView.builder(
              itemCount: provider.searchedTodos.length,
              itemBuilder: (context, index) {
                final todo = provider.searchedTodos[index];
                return ListTile(
                  title: Text(todo.title ?? ""),
                  leading: Checkbox(
                    value: todo.completed,
                    onChanged: (val) {
                      provider.patchTodoOptimistic(todo.id!, val ?? false);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuggestions(TodosProvider provider) {
    final recent = provider.recentSearches; // simpan list recent di provider
    final suggestions = ["delectus", "et porro", "voluptatem", "quis ut nam"];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (recent.isNotEmpty) ...[
          const Text(
            "Recent searches",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            children: recent
                .map(
                  (q) => ActionChip(
                    label: Text(q),
                    onPressed: () {
                      provider.searchTodosDebounced(q);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
        const Text(
          "Try searching for",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          children: suggestions
              .map(
                (q) => ActionChip(
                  label: Text(q),
                  onPressed: () {
                    provider.searchTodosDebounced(q);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
