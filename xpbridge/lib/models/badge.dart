import 'package:flutter/material.dart';

class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String earnedFrom;
  final Color color;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.earnedFrom,
    this.color = const Color(0xFF4C6FFF),
  });
}
