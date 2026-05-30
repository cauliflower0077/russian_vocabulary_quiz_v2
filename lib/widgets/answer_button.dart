// lib/widgets/answer_button.dart

import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String text;

  final VoidCallback onTap;

  final bool disabled;

  const AnswerButton({
    super.key,
    required this.text,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: disabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 18,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}