import 'package:flutter/material.dart';

class NamedIcon extends StatelessWidget {
  const NamedIcon({
    super.key,
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        ),
      ),
    );
  }
}
