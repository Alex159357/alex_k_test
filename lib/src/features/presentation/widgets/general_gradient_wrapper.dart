


import 'package:flutter/material.dart';

class GeneralGradientWrapper extends StatelessWidget {
  final Widget child;
  const GeneralGradientWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF73EC8B),
            Color(0xFF54C392),
            Color(0xFF15B392),
          ],
        ),
      ),
      child: child,
    );
  }
}
