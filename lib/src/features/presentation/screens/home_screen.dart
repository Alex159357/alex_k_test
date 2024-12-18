import 'package:alex_k_test/src/core/exceptions/context.dart';
import 'package:alex_k_test/src/core/exceptions/on_user_bloc.dart';
import 'package:alex_k_test/src/features/domain/states/auth_state.dart';
import 'package:alex_k_test/src/features/domain/states/general_screen_state.dart';
import 'package:alex_k_test/src/features/presentation/blocs/user/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/user/state.dart';
import 'package:alex_k_test/src/features/presentation/views/auth_view.dart';
import 'package:alex_k_test/src/features/presentation/views/error_view.dart';
import 'package:alex_k_test/src/features/presentation/views/loading_view.dart';
import 'package:alex_k_test/src/features/presentation/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    context.userBloc.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        body: _getHomeScreenBody,
      ),
    );
  }

  //Getters for Bloc components
  Widget get _getHomeScreenBody => BlocBuilder<UserBloc, UserState>(
        buildWhen: _buildWhenHomeScreen,
        builder: _homeScreenBodyBuilder,
      );

  Widget get _getAuthHandleBody => BlocBuilder<UserBloc, UserState>(
        buildWhen: _buildWhenAuthCondition,
        builder: _authBodyBuilder,
      );

  //builders
  Widget _homeScreenBodyBuilder(BuildContext context, UserState state) =>
      switch (state.screenState) {
        InitialScreenState() => _getAuthHandleBody,
        LoadingScreenState() => const LoadingView(),
        ErrorScreenState() =>
          ErrorView(message: (state.screenState as ErrorScreenState).message, onGotIt: ()=> context.userBloc.init(),),
      };

  Widget _authBodyBuilder(BuildContext context, UserState state) =>
      switch (state.authState) {
        UnAuthenticated() => const AuthView(),
        Authenticated() => const MainView(),
      };

  //control of conditions
  bool _buildWhenHomeScreen(UserState previous, UserState current) =>
      previous.screenState != current.screenState;

  bool _buildWhenAuthCondition(UserState previous, UserState current) =>
      previous.authState != current.authState;
}
