import 'package:get/get.dart';
import 'package:dio/dio.dart';
class NotificationService extends GetConnect {
    final Dio dio = Dio();
  @override
  String? baseUrl = "http://localhost:8000/api";

  Future<List> getNotifications(userId) async {
    final res = await get("/notifications/$userId");

    print("STATUS => ${res.statusCode}");
    print("BODY => ${res.body}");

    if (res.body == null || res.body is! List) {
      return [];
    }

    return List.from(res.body);
  }

  Future<void> read(id) async {
    await post("/notifications/read/$id", {});
  }
  Future<int> getUnreadCount(int userId) async {

  final response = await dio.get(
    "$baseUrl/notifications/unread/$userId"
  );

  return response.data['count'];

}
}