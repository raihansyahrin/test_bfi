import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:test_bfi/features/todos/data/datasources/lcoal/local_datasources.dart';
import 'package:test_bfi/features/todos/data/datasources/remote/remote_datasources.dart';
import 'package:test_bfi/features/todos/data/repositories/todos_repository_impl.dart';
import 'package:test_bfi/features/todos/domain/repositories/todos_repository.dart';
import 'package:test_bfi/features/todos/domain/usecases/delete_todo_usecase.dart';
import 'package:test_bfi/features/todos/domain/usecases/get_todos_usecase.dart';
import 'package:test_bfi/features/todos/domain/usecases/patch_todo_usecase.dart';
import 'package:test_bfi/features/todos/domain/usecases/post_todo_usecase.dart';
import 'package:test_bfi/features/todos/presentation/provider/todos_provider.dart';

final sl = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    // Register Http Client
    sl.registerLazySingleton<http.Client>(
      () => CustomHttpClient(http.Client()),
    );

    // Datasource
    sl.registerSingleton<RemoteDatasources>(
      RemoteDatasourcesImpl(client: sl()),
    );
    sl.registerSingleton<LocalDatasources>(LocalDatasources());

    // Repository
    sl.registerSingleton<TodosRepository>(
      TodosRepositoryImpl(remoteDatasourcesImpl: sl(), localDatasources: sl()),
    );

    // Usecase
    sl.registerSingleton<GetTodosUsecase>(
      GetTodosUsecase(todosRepository: sl<TodosRepository>()),
    );
    sl.registerSingleton<PatchTodoUsecase>(
      PatchTodoUsecase(todosRepository: sl<TodosRepository>()),
    );
    sl.registerSingleton<PostTodoUsecase>(
      PostTodoUsecase(todosRepository: sl<TodosRepository>()),
    );

    sl.registerSingleton<DeleteTodoUsecase>(
      DeleteTodoUsecase(todosRepository: sl<TodosRepository>()),
    );

    // Provider
    sl.registerFactory<TodosProvider>(
      () => TodosProvider(
        sl<GetTodosUsecase>(),
        sl<PatchTodoUsecase>(),
        sl<PostTodoUsecase>(),
        sl<DeleteTodoUsecase>(),
      ),
    );
  }
}

class CustomHttpClient extends http.BaseClient {
  final http.Client _inner;

  CustomHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll({
      "Accept": "application/json",
      "Content-Type": "application/json",
      "User-Agent": "FlutterApp/1.0",
    });
    return _inner.send(request);
  }
}
