import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  final bool isLoading;
  final double height;
  final double width;
  final Color? color;
  final String? imageName;
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.isLoading,
    required this.height,
    required this.width,
    this.color,
    this.imageName,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: imageName != null
          ? Image.asset(
              imageName!,
              height: 24,
              width: 24,
              color: color != null
                  ? Colors.white
                  : Theme.of(context).colorScheme.surface,
            )
          : const SizedBox.shrink(),
      onPressed: onPressed,
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
