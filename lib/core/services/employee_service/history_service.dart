import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';


class HistoryService {

final String baseUrl =
"http://localhost:8000/api";


Future<Map<String,dynamic>> getHistory(int id) async {


final response =
await http.get(
Uri.parse(
"$baseUrl/employee/history/$id"
),
headers: AuthService.authHeaders
);


if(response.statusCode==200){

return jsonDecode(response.body);

}


throw Exception(
response.body
);


}


}