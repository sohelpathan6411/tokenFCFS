import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final double borderRadius;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    this.textColor,
    this.backgroundColor,
    this.borderRadius = 8.0,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor ?? Colors.white,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColorDark,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(text),
    );
  }
}
