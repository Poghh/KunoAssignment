import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final String color;
  final String icon;

  @override
  List<Object?> get props => <Object?>[id, name, color, icon];
}
