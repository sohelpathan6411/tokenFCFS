import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Color? borderColor;
  final ValueChanged<String> onChanged;
  final int? maxLength;
  final List<TextInputFormatter>? inputformate;

  const CustomTextField(
      {Key? key,
      required this.label,
      this.controller,
      this.keyboardType = TextInputType.text,
      this.obscureText = false,
      this.borderColor,
      required this.onChanged,
      this.maxLength,
      this.inputformate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputformate,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: borderColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColorDark,
          ),
        ),
      ),
    );
  }
}
