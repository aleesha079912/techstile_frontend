import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';


class FactoryDashboardService{


final String baseUrl =
"http://localhost:8000/api/factories";


Future<Map<String,dynamic>> getDashboard(
String id
)async{


final response =
await http.get(
Uri.parse(
"$baseUrl/dashboard/$id"
),
headers: AuthService.authHeaders
);



if(response.statusCode==200){

return jsonDecode(response.body);

}


throw Exception("Dashboard failed");


}


}