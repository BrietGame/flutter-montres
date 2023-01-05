import 'dart:convert';
import 'dart:ffi';

class Montre {
  final String? id;
  final String? title;
  final double? price;
  final String? image;

  const Montre({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
  });

  factory Montre.fromJson(Map<String, dynamic> json) {
    return Montre(
      id: json['_id'] as String,
      title: json['title'] as String,
      price: json['price'] as double,
      image: json['image'] as String,
    );
  }
}