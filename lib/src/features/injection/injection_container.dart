import 'package:alex_k_test/firebase_options.dart';
import 'package:alex_k_test/src/core/database/data_base_providers/map_pin_database.dart';
import 'package:alex_k_test/src/core/database/data_base_providers/sync_queue_database.dart';
import 'package:alex_k_test/src/core/database/data_base_providers/user_database.dart';
import 'package:alex_k_test/src/core/database/database_helper.dart';
import 'package:alex_k_test/src/core/network/network_info.dart';
import 'package:alex_k_test/src/core/utils/mappers/map_pin_mapper.dart';
import 'package:alex_k_test/src/core/utils/mappers/universal_mapper.dart';
import 'package:alex_k_test/src/core/utils/permissions/permissions_handler.dart';
import 'package:alex_k_test/src/core/utils/shared_preferanse/secure_storage.dart';
import 'package:alex_k_test/src/features/data/datasources/local/local_data_source_impl.dart';
import 'package:alex_k_test/src/features/data/datasources/local/local_data_sourse.dart';
import 'package:alex_k_test/src/features/data/datasources/remote/remote_data_source.dart';
import 'package:alex_k_test/src/features/data/datasources/remote/remote_data_sourse_impl.dart';
import 'package:alex_k_test/src/features/data/repositories/map_pin_repository_impl.dart';
import 'package:alex_k_test/src/features/data/repositories/sync_queue_repository_impl.dart';
import 'package:alex_k_test/src/features/data/repositories/user_repository_impl.dart';
import 'package:alex_k_test/src/features/domain/repositories/map_pins_repository.dart';
import 'package:alex_k_test/src/features/domain/repositories/sync_queue_repository.dart';
import 'package:alex_k_test/src/features/domain/repositories/user_repository.dart';
import 'package:alex_k_test/src/features/domain/usecases/pin_usecase.dart';
import 'package:alex_k_test/src/features/domain/usecases/sync_queue_usecase.dart';
import 'package:alex_k_test/src/features/domain/usecases/user_usecase.dart';
import 'package:alex_k_test/src/features/presentation/blocs/add_map_pin/bloc.dart';
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
    await _initFirebase();
    _initBlocs();
    _initUseCases();
    _initRepositories();
    _initTools();
    await _initData();
  }

  static InjectionContainer get instance => InjectionContainer();

  Future<void> _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    getIt.registerLazySingleton(() => FirebaseAuth.instance);
    getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  }

  void _initBlocs() {
    getIt.registerLazySingleton<UserBloc>(() => UserBloc(getIt(), getIt()));
    getIt.registerLazySingleton<MapPinBloc>(() => MapPinBloc(getIt()));
  }

  void _initUseCases() {
    getIt.registerLazySingleton(() => UserUseCase(getIt()));
    getIt.registerLazySingleton(() => PinUseCase(getIt()));
    getIt.registerLazySingleton(() => SyncQueueUseCase(getIt()));
  }

  void _initRepositories() {
    getIt.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(getIt(), getIt(), getIt(), getIt()));

    getIt.registerLazySingleton<MapPinsRepository>(
        () => MapPinRepositoryImpl(getIt(), getIt()));

    getIt.registerLazySingleton<SyncQueueRepository>(
        () => SyncQueueRepositoryImpl(getIt()));
  }

  void _initTools() {
    getIt.registerLazySingleton(() => Connectivity());
    getIt.registerLazySingleton(() => NetworkInfo(getIt()));
    getIt.registerSingletonAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance(),
    );
    getIt.registerLazySingleton(() => SecureStorageController(getIt()));
    getIt.registerLazySingleton(() => PermissionsHandler());
  }

  Future<void> _initData() async {
    getIt.registerLazySingleton(() => DatabaseHelper());
    getIt.registerLazySingleton(() => UserDatabase(getIt()));
    getIt.registerLazySingleton(() => MapPinDatabase(getIt()));
    getIt.registerLazySingleton(() => SyncQueueDatabase(getIt()));
    getIt.registerLazySingleton(() => UniversalMapper());
    getIt.registerLazySingleton(() => MapPinMapper());
    getIt.registerLazySingleton<RemoteDataSource>(
      () => RemoteDataSourceImpl(authClient: getIt<FirebaseAuth>()),
    );
    getIt.registerLazySingleton<LocalDataSource>(
        () => LocalDataSourceImpl(getIt(), getIt(), getIt()));
  }
}

final injector = InjectionContainer.instance;
