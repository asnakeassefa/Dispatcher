import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final bool isLoading;
  final double height;
  final double width;
  final Color? color;
  final String? imageName;
  final int? borderRadius;
  final IconData? icon;
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.isLoading,
    required this.height,
    required this.width,
    this.color,
    this.imageName,
    this.borderRadius,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon != null
          ? Icon(
              icon,
              color: color != null
                  ? Colors.white
                  : Theme.of(context).colorScheme.surface,
            )
          : const SizedBox.shrink(),
      onPressed: onPressed,
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius?.toDouble() ?? 8),
                side: BorderSide(
                  color: color ?? Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
      label: isLoading
          ? SizedBox(
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 35,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: color != null
                    ? Colors.white
                    : Theme.of(context).colorScheme.surface,
                fontSize: 16,
              ),
            ),
    );
  }
}
