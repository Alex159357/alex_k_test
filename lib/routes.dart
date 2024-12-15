import 'package:alex_k_test/src/features/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'src/features/presentation/screens/first_screen.dart';
import 'src/features/presentation/screens/second_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
        '/': (context) => const HomeScreen(),
        '/second': (context) => const SecondScreen(),
      };
}
