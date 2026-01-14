import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'features/api_requests/presentation/bloc/request_bloc.dart';
import 'features/api_requests/data/datasources/request_local_datasource.dart';
import 'features/api_requests/data/datasources/request_remote_datasource.dart';
import 'features/api_requests/data/repositories/request_repository_impl.dart';
import 'features/api_requests/domain/repositories/request_repository.dart';
import 'features/api_requests/domain/usecases/delete_request.dart';
import 'features/api_requests/domain/usecases/get_saved_requests.dart';
import 'features/api_requests/domain/usecases/save_request.dart';
import 'features/api_requests/domain/usecases/send_request.dart';


final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  // ============================================
  // Features - API Request
  // ============================================

  // BLoC
  sl.registerFactory(
        () => RequestBloc(
      sendRequest: sl(),
      saveRequest: sl(),
      getSavedRequests: sl(),
      deleteRequest: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SendRequest(sl()));
  sl.registerLazySingleton(() => SaveRequest(sl()));
  sl.registerLazySingleton(() => GetSavedRequests(sl()));
  sl.registerLazySingleton(() => DeleteRequest(sl()));

  // Repository
  sl.registerLazySingleton<RequestRepository>(
        () => RequestRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<RequestRemoteDataSource>(
        () => RequestRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<RequestLocalDataSource>(
        () => RequestLocalDataSourceImpl(),
  );

  // ============================================
  // External Dependencies
  // ============================================

  // HTTP Client
  sl.registerLazySingleton(() => http.Client());

  // Initialize Hive
  await Hive.initFlutter();
}
