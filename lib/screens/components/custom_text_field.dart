import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.groupNameController,
    required this.hintText,
    this.focusNode,
    this.numKeyboardType = false,
  });

  final TextEditingController groupNameController;
  final String hintText;
  final focusNode;
  final bool numKeyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        autofocus: true,
        focusNode: focusNode ?? FocusNode(),
        cursorColor: Colors.green,
        controller: groupNameController,
        keyboardType:
            numKeyboardType ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.green,
              ),
              borderRadius: BorderRadius.circular(7),
            )),
      ),
    );
  }
}
