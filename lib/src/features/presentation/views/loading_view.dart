

import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: SizedBox(
          width: 150,
          height: 150,
          child:  CircularProgressIndicator(),
        ),
      ),
    );
  }
}
