

import 'package:alex_k_test/src/features/presentation/blocs/add_map_pin/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/sync/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/user/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension OnContext on BuildContext{
  
  UserBloc get userBloc => BlocProvider.of<UserBloc>(this);
  MapPinBloc get mapPinBloc => BlocProvider.of<MapPinBloc>(this);
  SyncBloc get syncBloc => BlocProvider.of<SyncBloc>(this);

  ThemeData get theme => Theme.of(this);

  Size get screenSize => MediaQuery.of(this).size;

  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;

  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  void pushNamed(String route, {Map<String, dynamic>? args}) => Navigator.of(this).pushNamed(route, arguments: args);

  void pop({Map<String, dynamic>? args}) => Navigator.of(this).pop(args);
}