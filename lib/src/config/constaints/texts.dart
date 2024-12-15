

import 'package:flutter/foundation.dart';

class Texts{
  static const HintsTexts hints = HintsTexts();
  static const ButtonTexts buttonTexts = ButtonTexts();
  static const LabelsTexts labels = LabelsTexts();
}

@immutable
class HintsTexts{
  final String enterEmail;
  final String enterPassword;

  const HintsTexts({
    this.enterEmail = "Enter email",
    this.enterPassword = "Enter password",
  });
}

@immutable
class ButtonTexts{
  final String login;

  const ButtonTexts({
    this.login = "Login"
  });
}

@immutable
class LabelsTexts{
  final String demoUser;
  final String login;
  final String logOut;

  const LabelsTexts({
    this.demoUser = "Demo User",
    this.login = "Login",
    this.logOut = "Log Out"
  });
}