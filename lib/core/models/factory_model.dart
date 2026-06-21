class FactoryModel {
  final int id; // ❗ MUST be int

  final String name;
  final String address;
  final String city;

  FactoryModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
  });

  factory FactoryModel.fromJson(Map<String, dynamic> json) {
    return FactoryModel(
      id: int.parse(json['id'].toString()), // 🔥 FIX HERE
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
    );
  }
}