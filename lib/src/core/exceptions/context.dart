

import 'package:alex_k_test/src/features/presentation/blocs/user/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension OnContext on BuildContext{
  UserBloc get userBloc => BlocProvider.of<UserBloc>(this);

  ThemeData get theme => Theme.of(this);

  Size get screenSize => MediaQuery.of(this).size;

  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;

  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
}