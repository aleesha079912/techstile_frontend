import 'dart:convert';
import 'package:http/http.dart' as http;

class UserData {
  final int? id; // Backend se integer ID aati hai
  final String name, email, phone, cnic, address, role, details, pic;

  UserData({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.address,
    required this.role,
    required this.details,
    this.pic = "",
  });

  // JSON ko UserData object mein badalne ke liye
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone_no'] ?? '', // Backend column name 'phone_no' hai
      cnic: json['cnic'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? '',
      details: json['employee_details'] ?? '', // Backend column name 'employee_details'
      pic: json['pic'] ?? '',
    );
  }

  // Object ko JSON mein badalne ke liye (Add/Update ke liye)
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone_no": phone,
      "cnic": cnic,
      "address": address,
      "role": role,
      "employee_details": details,
      "pic": pic,
    };
  }
}

class ManageUsersService {
  static final ManageUsersService instance = ManageUsersService._();
  ManageUsersService._();

  // IP Address: Web ke liye 'localhost' aur Android ke liye '10.0.2.2'
  final String baseUrl = "http://localhost:8000/api/users"; 

  // ✅ Get All Users
  Future<List<UserData>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/all'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((json) => UserData.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }

  // ✅ Add User
  Future<bool> addUser(UserData user, String password) async {
    try {
      Map<String, dynamic> data = user.toJson();
      data['password'] = password; // Password alag se add kiya

      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ✅ Update User
  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/$id'),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ✅ Delete User
  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/delete/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}