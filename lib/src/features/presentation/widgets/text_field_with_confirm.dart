import 'package:flutter/material.dart';

import 'general_text_field.dart';

class TextFieldWithConfirm extends StatefulWidget {
  final Function(String) onSend;
  final String initialText;

  const TextFieldWithConfirm({
    super.key,
    required this.onSend,
    this.initialText = "",
  });

  @override
  _TextFieldWithConfirmState createState() => _TextFieldWithConfirmState();
}

class _TextFieldWithConfirmState extends State<TextFieldWithConfirm> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GeneralTextField(
            initialText: widget.initialText,
            onChanged: (v) => _controller.text = v,
          ),
        ),
        IconButton(onPressed: (){
          widget.onSend(_controller.text);
          _controller.text = "";
          FocusScope.of(context).requestFocus(FocusNode());
        }, icon: const Icon(Icons.send))
      ],
    );
  }
}
