

import 'package:alex_k_test/src/config/constaints/texts.dart';
import 'package:alex_k_test/src/core/exceptions/context.dart';
import 'package:alex_k_test/src/features/presentation/widgets/general_primary_button.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onGotIt;
  const ErrorView({this.message = "Unknown Error",  required this.onGotIt, super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
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
            ),
            const SizedBox(height: 26,),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: GeneralPrimaryButton(text: Texts.buttonTexts.gotIt, backgroundColor: context.theme.primaryColor, onPressed: onGotIt),
            )
          ],
        ),
      ),
    );
  }
}
