import 'package:alex_k_test/firebase_options.dart';
import 'package:alex_k_test/src/core/database/data_base_providers/user_database.dart';
import 'package:alex_k_test/src/core/database/database_helper.dart';
import 'package:alex_k_test/src/core/network/network_info.dart';
import 'package:alex_k_test/src/core/utils/mappers/user_mapper.dart';
import 'package:alex_k_test/src/core/utils/shared_preferanse/secure_storage.dart';
import 'package:alex_k_test/src/features/data/datasources/local/local_data_source_impl.dart';
import 'package:alex_k_test/src/features/data/datasources/local/local_data_sourse.dart';
import 'package:alex_k_test/src/features/data/datasources/remote/remote_data_source.dart';
import 'package:alex_k_test/src/features/data/datasources/remote/remote_data_sourse_impl.dart';
import 'package:alex_k_test/src/features/data/repositories/user_repository_impl.dart';
import 'package:alex_k_test/src/features/domain/repositories/user_repository.dart';
import 'package:alex_k_test/src/features/domain/use_cases/user_use_case.dart';
import 'package:alex_k_test/src/features/presentation/blocs/user/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

late GetIt getIt;

class InjectionContainer {
  Future<void> init() async {
    getIt = GetIt.instance;
    _initBlocs();
    _initUseCases();
    _initRepositories();
    _initTools();
    await _initData();
  }

  static InjectionContainer get instance => InjectionContainer();

  void _initBlocs() {
    getIt.registerLazySingleton<UserBloc>(() => UserBloc(getIt()));
  }

  void _initUseCases() {
    getIt.registerLazySingleton(() => UserUseCase(getIt()));
  }

  void _initRepositories() {
    getIt.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(getIt(), getIt(), getIt(), getIt()));
  }

  void _initTools() {
    getIt.registerLazySingleton(() => Connectivity());
    getIt.registerLazySingleton(() => NetworkInfo(getIt()));
    getIt.registerSingletonAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance(),
    );
    getIt.registerLazySingleton(() => SecureStorageController(getIt()));
  }

  Future<void> _initData() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    getIt.registerLazySingleton(() => FirebaseAuth.instance);
    getIt.registerLazySingleton(() => FirebaseFirestore.instance);
    getIt.registerLazySingleton(() => DatabaseHelper());
    getIt.registerLazySingleton(() => UserDatabase(getIt()));
    getIt.registerLazySingleton(() => UserMapper());
    getIt.registerLazySingleton<RemoteDataSource>(() => RemoteDataSourceImpl());
    getIt.registerLazySingleton<LocalDataSource>(
        () => LocalDataSourceImpl(getIt(), getIt()));
  }
}

final injector = InjectionContainer.instance;
