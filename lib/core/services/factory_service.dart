import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/factory_model.dart';
import 'auth_service.dart';

class FactoryController extends GetxController {
  var factoryList = <FactoryModel>[].obs;
  var isLoading = false.obs;
  final String baseUrl = "http://localhost:8000/api/factories";

  @override
  void onInit() {
    super.onInit();
    fetchFactories(); 
  }

  // 1. GET ALL (Backend index function)
  Future<void> fetchFactories() async {
  final token = AuthService.token; // ya jaise bhi token lo
  print("🔑 Token: $token");       // ← token print karo
  final box = GetStorage();

  print("Token: box.read('token') = ${box.read('token')}"); // ← GetStorage se bhi check karo
  final response = await http.get(
    Uri.parse('$baseUrl/allfactories'),
    headers: AuthService.authHeaders,
  );
  if (response.statusCode == 200) {
  final res = jsonDecode(response.body);
  if (res['status'] == true) {        // ← 'status' hai ya 'success'?
    List<dynamic> data = res['data'];
    factoryList.assignAll(
      data.map((e) => FactoryModel.fromJson(e)).toList()
    );
  }
}  
}

  // 2. CREATE (Backend store function)
  Future<bool> addFactory(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addfactory'),
        headers: AuthService.authHeaders,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['status'] == true) {
          await fetchFactories(); // List refresh 
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error adding factory: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 3. UPDATE (Backend update function)
  Future<bool> updateFactory(dynamic id, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updatefactory/$id'),
        headers: AuthService.authHeaders,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        await fetchFactories();
        return true;
      }
      return false;
    } catch (e) {
      print("Update Error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 4. DELETE (Backend destroy function)
  Future<void> deleteFactory(dynamic id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/deletefactory/$id'),
       headers: AuthService.authHeaders,
       );
      
      if (response.statusCode == 200) {
        factoryList.removeWhere((f) => f.id == id);
        Get.snackbar("Success", "Factory deleted from server");
      }
    } catch (e) {
      Get.snackbar("Error", "Could not delete factory");
    }
  }
}