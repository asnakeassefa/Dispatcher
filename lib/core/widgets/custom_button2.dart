import 'package:flutter/material.dart';

class CustomButtonOut extends StatelessWidget {
  final void Function() onPressed;
  final Widget content;
  final bool isLoading;
  final double height;
  final double width;
  const CustomButtonOut({
    super.key,
    required this.onPressed,
    required this.content,
    required this.isLoading,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        minimumSize: Size(width, height),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: isLoading
          ? CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            )
          :
            // : Text(
            //     text,
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontSize: 16,
            //     ),
            //   ),
            content,
    );
  }
}
