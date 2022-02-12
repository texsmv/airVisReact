import 'package:airq/app/constants/colors.dart';
import 'package:flutter/material.dart';

class PCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color color;
  const PCard({
    Key? key,
    required this.child,
    this.padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    this.borderRadius = 6,
    this.color = pColorBackground,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
      child: child,
    );
  }
}
