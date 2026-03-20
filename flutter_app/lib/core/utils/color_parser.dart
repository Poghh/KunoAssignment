import 'package:flutter/material.dart';

Color parseHexColor(
  String? hex, {
  required Color fallback,
}) {
  if (hex == null || hex.isEmpty) {
    return fallback;
  }

  final String normalized = hex.replaceFirst('#', '');
  if (normalized.length != 6) {
    return fallback;
  }

  final int? value = int.tryParse('FF$normalized', radix: 16);
  if (value == null) {
    return fallback;
  }

  return Color(value);
}
