

import 'package:alex_k_test/src/core/exceptions/context.dart';
import 'package:flutter/material.dart';

class GeneralContainer extends StatelessWidget {
  final Widget child;
  const GeneralContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      child: Container(
        color: context.theme.scaffoldBackgroundColor,
          child: child),
    );
  }
}
