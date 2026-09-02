class FactoryModel {
  final int id;

  final String name;
  final String address;
  final String city;
  final bool isActive;

  FactoryModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.isActive = false,
  });

  factory FactoryModel.fromJson(Map<String, dynamic> json) {
    return FactoryModel(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      isActive: json['is_active'] == true,
    );
  }
}
