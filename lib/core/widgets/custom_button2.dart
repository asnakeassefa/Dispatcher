import 'package:flutter/material.dart';

class CustomButtonOut extends StatelessWidget {
  final void Function() onPressed;
  final Widget content;
  final bool isLoading;
  final double height;
  final double width;
  final Color? color;
  final Color? bgColor;
  final int? borderRadius;

  const CustomButtonOut({
    super.key,
    required this.onPressed,
    required this.content,
    required this.isLoading,
    required this.height,
    required this.width,
    this.color,
    this.borderRadius,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
        backgroundColor: WidgetStateProperty.all<Color>(
          bgColor ?? Theme.of(context).colorScheme.surface,
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius?.toDouble() ?? 8),
            side: BorderSide(
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
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
