import 'package:flutter/material.dart';

class GeneralTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final bool passwordVisibilityState;
  final Function(String)? onChanged;
  final Function(bool)? onShowPassword;
  final Function(String)? onSubmitted;

  const GeneralTextField(
      {super.key,
      this.hintText = "Enter text",
      this.isPassword = false,
        this.passwordVisibilityState = false,
      this.onChanged,
        this.onShowPassword,
      this.onSubmitted});

  @override
  State<GeneralTextField> createState() => _GeneralTextFieldState();
}

class _GeneralTextFieldState extends State<GeneralTextField> {
  late TextEditingController? controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: widget.isPassword? widget.passwordVisibilityState : false,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Icon(
            Icons.edit,
            color: Colors.grey.shade400,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    widget.passwordVisibilityState? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: (){
                    if(widget.onShowPassword != null){
                      widget.onShowPassword!(!widget.passwordVisibilityState);
                    }
                  },
                )
              : null,
        ),
      ),
    );
  }
}
