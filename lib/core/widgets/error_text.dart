import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  const ErrorText({
    super.key,
    required this.text,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color.fromARGB(255, 184, 37, 35),
        ),
        textAlign: textAlign ?? TextAlign.left,
      ),
    );
  }
}