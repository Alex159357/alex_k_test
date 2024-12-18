import 'package:alex_k_test/src/config/constaints/texts.dart';
import 'package:alex_k_test/src/core/exceptions/context.dart';
import 'package:alex_k_test/src/core/exceptions/on_user_bloc.dart';
import 'package:alex_k_test/src/features/domain/states/auth_state.dart';
import 'package:alex_k_test/src/features/presentation/blocs/user/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/user/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_getProfile],
    );
  }

  Widget get _getProfile =>
      BlocBuilder<UserBloc, UserState>(builder: _getProfileBuilder);

  Widget _getProfileBuilder(BuildContext context, UserState state) {
    if (state.authState is Authenticated) {
      final user = (state.authState as Authenticated).userEntity;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: context.theme.colorScheme.primaryContainer,
              child: const Icon(
                Icons.person,
                weight: 100,
              ),
            ),
            const SizedBox(
              width: 24,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    child: Text(
                      user.userName.toString(),
                      style: context.theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w100),
                    ),
                  ),
                  if (user.isDemo) Text(Texts.labels.demoUser)
                ],
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            user.isDemo
                ? Column(
                    children: [
                      IconButton(
                          onPressed: () => context.userBloc.loginPressed(),
                          icon: const Icon(Icons.login)),
                      Text(Texts.labels.login),
                      //DISPLAY LOGIN FORM
                    ],
                  )
                : Column(
                    children: [
                      IconButton(
                          onPressed: () => context.userBloc.logOut(),
                          icon: const Icon(Icons.logout_rounded)),
                      Text(Texts.labels.logOut)
                    ],
                  )
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
