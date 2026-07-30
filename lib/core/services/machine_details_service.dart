import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MachineDetailsService extends GetxController {
  RxBool loading = true.obs;

  RxMap<String, dynamic> data = <String, dynamic>{}.obs;

  Future<void> getMachineDetails(String machineId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://techstile.sandbox.pk/api/machines/details/$machineId",
        ),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        data.value = jsonDecode(response.body);
      }
    } finally {
      loading.value = false;
    }
  }
}
