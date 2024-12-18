import 'package:alex_k_test/src/config/constaints/texts.dart';
import 'package:alex_k_test/src/config/constaints/texts.dart';
import 'package:alex_k_test/src/core/exceptions/context.dart';
import 'package:alex_k_test/src/core/exceptions/on_user_bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/user/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/user/state.dart';
import 'package:alex_k_test/src/features/presentation/widgets/general_primary_button.dart';
import 'package:alex_k_test/src/features/presentation/widgets/general_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 26,
              ),
              _getLogo,
              const SizedBox(
                height: 26,
              ),
              _getEmailField,
              const SizedBox(
                height: 26,
              ),
              _getPasswordField,
              const SizedBox(
                height: 26,
              ),
              _geLoginButton
            ],
          ),
        ),
      ),
    );
  }

  //Getters for Bloc components
  Widget get _getEmailField => BlocBuilder<UserBloc, UserState>(
      buildWhen: _buildEmailFieldWhen, builder: _getEmailFieldBuilder);

  Widget get _getPasswordField => BlocBuilder<UserBloc, UserState>(
      buildWhen: _buildPasswordFieldWhen, builder: _getPasswordFieldBuilder);

  Widget get _geLoginButton => BlocBuilder<UserBloc, UserState>(
    buildWhen: _buildLoginButtonWhen,
       builder: _getLoginButtonBuilder);

//Builders
  Widget _getEmailFieldBuilder(BuildContext context, UserState state) =>
      GeneralTextField(
        initialText: state.email,
        hintText: Texts.hints.enterEmail,
        onChanged: (v) => context.userBloc.setEmail(v),
        onSubmitted: (v) {},
      );

  Widget _getPasswordFieldBuilder(BuildContext context, UserState state) =>
      GeneralTextField(
        isPassword: true,
        initialText: state.password,
        onShowPassword: (v) => context.userBloc.setPasswordVisibilityState(v),
        onChanged: (v) => context.userBloc.setPassword(v),
        onSubmitted: (v) {},
        passwordVisibilityState: state.passwordVisibilityState,
        hintText: Texts.hints.enterPassword,
      );

  Widget _getLoginButtonBuilder(BuildContext context, UserState state) =>
      GeneralPrimaryButton(
        text: Texts.buttonTexts.login,
        enabled: state.isFormValid,
        backgroundColor: context.theme.primaryColor,
        onPressed: () => context.userBloc.loginPressed(),
      );

  //UI Components
  Widget get _getLogo => Image.asset("assets/images/logo.png");


//control of conditions
  bool _buildEmailFieldWhen(UserState previous, UserState current) =>
      previous.email != current.email;

  bool _buildPasswordFieldWhen(UserState previous, UserState current) =>
      previous.password != current.password ||
      previous.passwordVisibilityState != current.passwordVisibilityState;

  bool _buildLoginButtonWhen(UserState previous, UserState current) =>
      previous.isFormValid != current.isFormValid;
}
