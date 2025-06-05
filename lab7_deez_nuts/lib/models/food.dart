class Food {
  final int? id;
  final String name;
  final int calories;
  final double price;
  final String category;

  Food({
    this.id,
    required this.name,
    required this.calories,
    required this.price,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'price': price,
      'category': category,
    };
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      price: map['price'],
      category: map['category'],
    );
  }

  Food copyWith({
    int? id,
    String? name,
    int? calories,
    double? price,
    String? category,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      price: price ?? this.price,
      category: category ?? this.category,
    );
  }
} 