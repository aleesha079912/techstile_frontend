class User {
  final String id;
  final String name;
  final String role;
  final String status;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
  });
}

class UsersService {
  Future<List<User>> fetchUsers() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate API

    return [
      User(
        id: "TC-49021",
        name: "Marcus Chen",
        role: "Senior Tech • 8 yrs",
        status: "AVAILABLE",
      ),
      User(
        id: "TC-22211",
        name: "Elena Rodriguez",
        role: "Master Weaver",
        status: "ON BREAK",
      ),
      User(
        id: "TC-87654",
        name: "Sarah Loomis",
        role: "Junior Operator",
        status: "AVAILABLE",
      ),
      User(
        id: "TC-11122",
        name: "Arthur Vance",
        role: "Technician II",
        status: "AVAILABLE",
      ),
    ];
  }
}