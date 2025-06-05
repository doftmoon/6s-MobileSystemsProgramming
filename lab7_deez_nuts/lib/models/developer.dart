class Developer {
  final int? id;
  final String name;
  final int experienceYears;
  final double salary;
  final String role;

  Developer({
    this.id,
    required this.name,
    required this.experienceYears,
    required this.salary,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'experienceYears': experienceYears,
      'salary': salary,
      'role': role,
    };
  }

  factory Developer.fromMap(Map<String, dynamic> map) {
    return Developer(
      id: map['id'],
      name: map['name'],
      experienceYears: map['experienceYears'],
      salary: map['salary'],
      role: map['role'],
    );
  }

  Developer copyWith({
    int? id,
    String? name,
    int? experienceYears,
    double? salary,
    String? role,
  }) {
    return Developer(
      id: id ?? this.id,
      name: name ?? this.name,
      experienceYears: experienceYears ?? this.experienceYears,
      salary: salary ?? this.salary,
      role: role ?? this.role,
    );
  }
}
