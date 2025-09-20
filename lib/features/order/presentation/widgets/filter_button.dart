import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_button2.dart';

class FillterButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String text;
  const FillterButton({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButtonOut(
      onPressed: () {
        // setState(() {
        //   _selectedIndex = 2;
        // });
        onTap();
      },
      content: Text(
        text,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      isLoading: false,
      borderRadius: 50,
      height: 40,
      width: 140,
      bgColor: isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surface,
      color: isSelected ? Theme.of(context).colorScheme.primary : null,
    );
  }
}
