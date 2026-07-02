import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';

class ManagerProfileService {

  Future<Map<String,dynamic>?> getProfile(
      dynamic userId,
  ) async {

    final response = await http.get(
      Uri.parse(
        '${AuthService.baseUrl}/manager/profile/$userId',
      ),
      headers: AuthService.authHeaders,
    );

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }

    return null;
  }
}