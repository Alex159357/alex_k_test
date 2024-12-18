

import 'package:alex_k_test/src/features/injection/injection_container.dart';
import 'package:alex_k_test/src/features/presentation/blocs/add_map_pin/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/user/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<BlocProvider> get getBlocs => [
  BlocProvider<UserBloc>(create: (context) => getIt.get<UserBloc>()),
  BlocProvider<MapPinBloc>(create: (context) => getIt.get<MapPinBloc>()),
];