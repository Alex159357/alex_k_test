import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class GeneralTextField extends StatefulWidget {
  final String hintText; // Text to display as the hint
  final bool isPassword; // Flag to determine if the field is for a password
  final bool passwordVisibilityState; // Determines if the password is visible
  final Function(String)? onChanged; // Callback when the text changes
  final Function(bool)? onShowPassword; // Callback to show/hide password
  final Function(String)? onSubmitted; // Callback when the user submits the text
  final bool allowEdit; // Flag to control whether the text field is editable
  final String initialText; // Initial text to set in the text field

  const GeneralTextField({
    super.key,
    this.hintText = "Enter text", // Default hint text
    this.isPassword = false, // Default is not a password field
    this.passwordVisibilityState = false, // Default password visibility is off
    this.onChanged,
    this.onShowPassword,
    this.onSubmitted,
    this.allowEdit = true, // Default is editable
    this.initialText = "", // Default initial text is empty
  });

  @override
  State<GeneralTextField> createState() => _GeneralTextFieldState();
}

class _GeneralTextFieldState extends State<GeneralTextField> {
  late TextEditingController controller; // Controller for managing text input

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the initial text provided
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    controller.text =  widget.initialText;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the container
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Shadow color
            spreadRadius: 2, // Shadow spread radius
            blurRadius: 8, // Blur radius for the shadow
            offset: const Offset(0, 4), // Offset of the shadow
          ),
        ],
      ),
      child: TextField(
        controller: controller, // Text controller for managing the text input
        obscureText: widget.isPassword ? widget.passwordVisibilityState : false,
        // If it's a password field, respect visibility state
        onChanged: widget.allowEdit ? widget.onChanged : null,
        // Disable onChanged if the field is not editable
        onSubmitted: widget.allowEdit ? widget.onSubmitted : null,
        // Disable onSubmitted if the field is not editable
        enabled: widget.allowEdit, // Control whether the text field is editable
        decoration: InputDecoration(
          hintText: widget.hintText, // Hint text displayed when the field is empty
          hintStyle: TextStyle(color: Colors.grey.shade400), // Style for hint text
          border: InputBorder.none, // No border around the text field
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          // Padding inside the text field
          prefixIcon: Icon(
            Icons.edit,
            color: widget.allowEdit ? Colors.grey.shade400 : Colors.transparent,
            // Red icon if the field is not editable
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(
              widget.passwordVisibilityState
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: Colors.grey.shade400,
            ),
            onPressed: widget.allowEdit
                ? () {
              // Toggle password visibility when the icon is pressed
              if (widget.onShowPassword != null) {
                widget.onShowPassword!(!widget.passwordVisibilityState);
              }
            }
                : null,
          )
              : null, // No suffix icon if it's not a password field
        ),
      ),
    );
  }
}
