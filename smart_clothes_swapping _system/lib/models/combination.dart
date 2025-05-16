class Combination {
  final int id;
  final String name;
  final String description;

  Combination({required this.id, required this.name, required this.description});

  factory Combination.fromJson(Map<String, dynamic> json) {
    return Combination(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}