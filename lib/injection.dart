import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'data/repositories/note_repository_impl.dart';
import 'data/services/note_api_service.dart';
import 'data/services/note_local_service.dart';
import 'domain/repositories/note_repository.dart';
import 'ui/notes/bloc/note_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton(() => http.Client());

  getIt.registerLazySingleton(
    () => NoteApiService(client: getIt()),
  );

  final localService = NoteLocalService();
  await localService.init();
  getIt.registerLazySingleton(() => localService);

  getIt.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(
      apiService: getIt(),
      localService: getIt(),
    ),
  );

  getIt.registerFactory(
    () => NoteBloc(repository: getIt()),
  );
}
