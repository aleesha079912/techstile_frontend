class FactoryModel {
  final dynamic id; // Isay dynamic rakhein taake int ya string dono chal sakein
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
      // .toString() lagane se agar backend se number (1) aaye ya string, 
      // aapka model usay handle kar lega
      id: json['id'].toString(), 
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "address": address,
      "city": city,
    };
  }
}