import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final bool isSelected;
  final String text;
  final double? height;
  final double? width;
  final IconData? icon;
  final Color? color;
  const StatusCard({
    super.key,
    required this.isSelected,
    required this.text,
    this.icon,
    this.color,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
      ),
      height: height?.toDouble() ?? 30,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // icon
          if (icon != null)
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          if (icon != null) const SizedBox(width: 8),
          // text
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            // style: TextStyle(
              
            //   color: isSelected
            //       ? Colors.white
            //       : Theme.of(context).textTheme.bodyMedium?.color,
            // ),
          ),
        ],
      ),
    );
  }
}
