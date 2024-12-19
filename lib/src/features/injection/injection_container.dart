import 'package:alex_k_test/firebase_options.dart';
import 'package:alex_k_test/src/core/database/data_base_providers/map_pin_database.dart';
import 'package:alex_k_test/src/core/database/data_base_providers/sync_queue_database.dart';
import 'package:alex_k_test/src/core/database/data_base_providers/user_database.dart';
import 'package:alex_k_test/src/core/database/database_helper.dart';
import 'package:alex_k_test/src/core/network/network_info.dart';
import 'package:alex_k_test/src/core/utils/location_service/location_service.dart';
import 'package:alex_k_test/src/core/utils/mappers/map_pin_mapper.dart';
import 'package:alex_k_test/src/core/utils/mappers/universal_mapper.dart';
import 'package:alex_k_test/src/core/utils/permissions/permissions_handler.dart';
import 'package:alex_k_test/src/core/utils/shared_preferanse/secure_storage.dart';
import 'package:alex_k_test/src/features/data/datasources/local/local_data_source_impl.dart';
import 'package:alex_k_test/src/features/data/datasources/local/local_data_sourse.dart';
import 'package:alex_k_test/src/features/data/datasources/remote/remote_data_source.dart';
import 'package:alex_k_test/src/features/data/datasources/remote/remote_data_source_impl.dart';
import 'package:alex_k_test/src/features/data/repositories/map_pin_repository_impl.dart';
import 'package:alex_k_test/src/features/data/repositories/sync_queue_repository_impl.dart';
import 'package:alex_k_test/src/features/data/repositories/user_repository_impl.dart';
import 'package:alex_k_test/src/features/domain/repositories/map_pins_repository.dart';
import 'package:alex_k_test/src/features/domain/repositories/sync_queue_repository.dart';
import 'package:alex_k_test/src/features/domain/repositories/user_repository.dart';
import 'package:alex_k_test/src/features/domain/usecases/location_usecase.dart';
import 'package:alex_k_test/src/features/domain/usecases/pin_usecase.dart';
import 'package:alex_k_test/src/features/domain/usecases/sync_queue_usecase.dart';
import 'package:alex_k_test/src/features/domain/usecases/user_usecase.dart';
import 'package:alex_k_test/src/features/presentation/blocs/add_map_pin/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/sync/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/user/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  final Logger _logger = Logger();
  late GetIt _getIt;

  factory InjectionContainer() {
    return _instance;
  }

  InjectionContainer._internal();

  static InjectionContainer get instance => _instance;
  GetIt get getIt => _getIt;

  Future<void> init() async {
    try {
      _getIt = GetIt.instance;

      // Core dependencies
      await _initFirebase();
      await _initCore();

      // Data layer
      await _initDataSources();
      _initRepositories();

      // Domain layer
      _initUseCases();

      // Presentation layer
      _initBlocs();

      _logger.i('Dependency injection initialized successfully');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize dependency injection',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _getIt.registerLazySingleton(() => FirebaseAuth.instance);
    _getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  }

  Future<void> _initCore() async {
    // Network
    _getIt.registerLazySingleton(() => Connectivity());
    _getIt.registerLazySingleton(() => NetworkInfo(_getIt()));

    // Storage
    await _initStorage();

    // Utils
    _getIt.registerLazySingleton(() => PermissionsHandler());
    _getIt.registerLazySingleton(() => UniversalMapper());
    _getIt.registerLazySingleton(() => MapPinMapper());
    _getIt.registerLazySingleton(() => LocationService());
  }

  Future<void> _initStorage() async {
    _getIt.registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance(),
    );
    await _getIt.isReady<SharedPreferences>();
    _getIt.registerLazySingleton(() => SecureStorageController(_getIt()));
  }

  Future<void> _initDataSources() async {
    // Database
    _getIt.registerLazySingleton(() => DatabaseHelper());
    _getIt.registerLazySingleton(() => UserDatabase(_getIt()));
    _getIt.registerLazySingleton(() => MapPinDatabase(_getIt()));
    _getIt.registerLazySingleton(() => SyncQueueDatabase(_getIt()));

    // Remote and Local data sources
    _getIt.registerLazySingleton<RemoteDataSource>(
      () => RemoteDataSourceImpl(
        authClient: _getIt<FirebaseAuth>(),
        firestore: _getIt<FirebaseFirestore>(),
      ),
    );
    _getIt.registerLazySingleton<LocalDataSource>(
      () => LocalDataSourceImpl(_getIt(), _getIt(), _getIt()),
    );
  }

  void _initRepositories() {
    _getIt.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(_getIt(), _getIt(), _getIt(), _getIt()),
    );
    _getIt.registerLazySingleton<MapPinsRepository>(
      () => MapPinRepositoryImpl(_getIt(), _getIt()),
    );
    _getIt.registerLazySingleton<SyncQueueRepository>(
      () => SyncQueueRepositoryImpl(
        _getIt<SyncQueueDatabase>(),
        _getIt<RemoteDataSource>(),
        _getIt<UniversalMapper>(),
        _getIt<LocalDataSource>(),
      ),
    );
  }

  void _initUseCases() {
    _getIt.registerLazySingleton(() => UserUseCase(_getIt()));
    _getIt.registerLazySingleton(() => PinUseCase(_getIt()));
    _getIt.registerLazySingleton(() => SyncQueueUseCase(_getIt()));
    _getIt.registerLazySingleton(() => LocationUseCase(_getIt()));
  }

  void _initBlocs() {
    _getIt.registerLazySingleton<UserBloc>(() => UserBloc(_getIt(), _getIt(), _getIt()));
    _getIt.registerLazySingleton<MapPinBloc>(() => MapPinBloc(
          _getIt<PinUseCase>(),
          _getIt<SyncQueueUseCase>(),
          _getIt<MapPinMapper>(),
          _getIt<UserUseCase>(),
        ));
    _getIt.registerLazySingleton<SyncBloc>(() => SyncBloc(_getIt()));
  }

  Future<void> dispose() async {
    await _getIt.reset();
    _logger.i('Dependency injection disposed');
  }
}

final injector = InjectionContainer();
