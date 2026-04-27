import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/factory_model.dart';

class FactoryController extends GetxController {
  var factoryList = <FactoryModel>[].obs;
  var isLoading = false.obs;

  // Laravel Server ka URL
  // Agar Chrome par hain: http://127.0.0.1:8000/api/factories
  // Agar Mobile par hain: http://APKA_IP_ADDRESS:8000/api/factories
  final String baseUrl = "http://127.0.0.1:8000/api/factories";

  @override
  void onInit() {
    super.onInit();
    fetchFactories(); // App start hotay hi data load ho jaye ga
  }

  // 1. GET ALL (Backend index function)
  Future<void> fetchFactories() async {
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse('$baseUrl/allfactories'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          List<dynamic> data = responseData['data'];
          factoryList.assignAll(data.map((e) => FactoryModel.fromJson(e)).toList());
        }
      }
    } catch (e) {
      print("Error fetching factories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. CREATE (Backend store function)
  Future<bool> addFactory(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addfactory'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['status'] == true) {
          await fetchFactories(); // List refresh karein
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
        headers: {"Content-Type": "application/json"},
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
      final response = await http.delete(Uri.parse('$baseUrl/deletefactory/$id'));
      
      if (response.statusCode == 200) {
        factoryList.removeWhere((f) => f.id == id);
        Get.snackbar("Success", "Factory deleted from server");
      }
    } catch (e) {
      Get.snackbar("Error", "Could not delete factory");
    }
  }
}