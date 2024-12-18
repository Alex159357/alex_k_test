import 'package:alex_k_test/src/features/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

import 'src/features/presentation/screens/add_edit_pin_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
        '/': (context) => const HomeScreen(),
        AddEditPinScreen.routeLocation: (context) => const AddEditPinScreen(),
      };
}
