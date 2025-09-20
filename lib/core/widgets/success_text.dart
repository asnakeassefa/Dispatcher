import 'package:flutter/material.dart';


class SuccessText extends StatelessWidget {
  final String successText;
  const SuccessText({super.key, required this.successText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: MediaQuery.sizeOf(context).width,
      child: Center(
        child: Text(
          successText,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
