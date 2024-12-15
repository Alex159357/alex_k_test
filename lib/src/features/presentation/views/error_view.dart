

import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  const ErrorView({this.message = "Unknown Error", super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          const Expanded(
            child: SizedBox(),
          ),
          const Icon(Icons.error_outline, color: Colors.redAccent, weight: 150,),
          const SizedBox(height: 26,),
          Text(message),
          const Expanded(
            child: SizedBox(),
          )
        ],
      ),
    );
  }
}
