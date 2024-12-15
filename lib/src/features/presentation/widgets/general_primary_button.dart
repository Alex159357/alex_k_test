

import 'package:flutter/material.dart';

class GeneralPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double elevation;
  final bool enabled;

  const GeneralPrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.borderRadius = 12.0,
    this.elevation = 4.0,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? backgroundColor : Colors.grey,
      borderRadius: BorderRadius.circular(borderRadius),
      elevation: enabled ? elevation : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: enabled ? onPressed : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: enabled ? textColor : Colors.white70,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}