

import 'package:flutter/foundation.dart';

class Texts{
  static const HintsTexts hints = HintsTexts();
  static const ButtonTexts buttonTexts = ButtonTexts();
  static const LabelsTexts labels = LabelsTexts();
  static const TitleTexts titles = TitleTexts();
  static const MessageTexts messageTexts = MessageTexts();
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
  final String save;
  final String gotIt;

  const ButtonTexts({
    this.login = "Login",
    this.save = "Save",
    this.gotIt = "Got It",
  });
}

@immutable
class LabelsTexts{
  final String demoUser;
  final String login;
  final String logOut;
  final String pinName;
  final String comments;

  const LabelsTexts({
    this.demoUser = "Demo User",
    this.login = "Login",
    this.logOut = "Log Out",
    this.pinName = "Pin Name",
    this.comments = "Comments",
  });
}

@immutable
class TitleTexts{
  final String menu;
  final String home;
  final String addPin;
  final String editPin;

  const TitleTexts({
    this.home = "Home",
    this.menu = "Menu",
    this.addPin = "Add new pin",
    this.editPin = "Edit pin comments"
  });
}

@immutable
class MessageTexts{
  final String latLngError;

  const MessageTexts({
    this.latLngError = "Error when receiving Longitude and Latitude of the selected position on the map"
  });
}