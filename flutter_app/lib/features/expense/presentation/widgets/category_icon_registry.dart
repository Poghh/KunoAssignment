import 'package:flutter/material.dart';

class CategoryIconOption {
  const CategoryIconOption({
    required this.key,
    required this.iconData,
  });

  final String key;
  final IconData iconData;
}

const List<CategoryIconOption> categoryIconOptions = <CategoryIconOption>[
  CategoryIconOption(key: 'category', iconData: Icons.category_rounded),
  CategoryIconOption(key: 'restaurant', iconData: Icons.restaurant_rounded),
  CategoryIconOption(
      key: 'directions_car', iconData: Icons.directions_car_rounded),
  CategoryIconOption(key: 'shopping_bag', iconData: Icons.shopping_bag_rounded),
  CategoryIconOption(key: 'lightbulb', iconData: Icons.lightbulb_rounded),
  CategoryIconOption(key: 'movie', iconData: Icons.movie_rounded),
  CategoryIconOption(
      key: 'health_and_safety', iconData: Icons.health_and_safety_rounded),
  CategoryIconOption(key: 'home', iconData: Icons.home_rounded),
  CategoryIconOption(
      key: 'local_grocery_store', iconData: Icons.local_grocery_store_rounded),
  CategoryIconOption(
      key: 'sports_esports', iconData: Icons.sports_esports_rounded),
  CategoryIconOption(key: 'flight', iconData: Icons.flight_rounded),
  CategoryIconOption(key: 'school', iconData: Icons.school_rounded),
  CategoryIconOption(key: 'work', iconData: Icons.work_rounded),
  CategoryIconOption(key: 'pets', iconData: Icons.pets_rounded),
  CategoryIconOption(key: 'cafe', iconData: Icons.local_cafe_rounded),
  CategoryIconOption(
      key: 'shopping_cart', iconData: Icons.shopping_cart_rounded),
];

IconData resolveCategoryIcon(String? iconKey) {
  final String normalized = (iconKey ?? '').trim();
  for (final CategoryIconOption option in categoryIconOptions) {
    if (option.key == normalized) {
      return option.iconData;
    }
  }
  return Icons.category_rounded;
}
