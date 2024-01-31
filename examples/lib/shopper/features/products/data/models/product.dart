import 'package:flutter/material.dart';

@immutable
class Product {
  Product(this.id, this.name)
      // To make the sample app look nicer, each item is given one of the
      // Material Design primary colors.
      : color = Colors.primaries[id % Colors.primaries.length];

  final int id;
  final String name;
  final Color color;
  final int price = 42;

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) => other is Product && other.id == id;
}
