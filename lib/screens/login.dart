import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:techstile_frontend/core/services/auth_service.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  GetStorage box = GetStorage();

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar("Error", "Email and Password are required");
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      final userName = result['data']['user']['name'];

      print(result['data']['token']);
      // ✅ store login state
      box.write('isLoggedIn', true);
      box.write('userName', userName);

      Get.offAllNamed('/dashboard');
    } else {
      Get.snackbar("Error", result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// LOGO TEXT
              Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.blueGrey),
                  SizedBox(width: 8),
                  Text(
                    "LOOMCONTROL",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey),
                  ),
                ],
              ),

              SizedBox(height: 20),

              /// TITLE
              Text(
                "Access",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2C5E)),
              ),

              Container(
                width: 40,
                height: 3,
                color: Colors.teal,
                margin: EdgeInsets.symmetric(vertical: 8),
              ),

              Text(
                "Enter your credentials to manage active looms and production logs.",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 20),

              /// WORKER ID
              Text("Email",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),

              SizedBox(height: 5),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Enter your Email",
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  fillColor: Color(0xFFF1F3F6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),

              SizedBox(height: 15),

              /// PASSWORD
              Text("PIN / PASSWORD",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),

              SizedBox(height: 5),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter your Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Color(0xFFF1F3F6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),

              SizedBox(height: 20),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 41, 13, 141),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                       ),
                      elevation: 0,
                    ),
                   child: _isLoading
                     ? CircularProgressIndicator(color: Colors.white)
                     : Text(
                    "Begin Shift  →",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              SizedBox(height: 10),

              Center(
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              SizedBox(height: 20),

              /// CONTACT
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.support_agent, color: Colors.teal),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text("Contact Supervisor"),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),

              SizedBox(height: 10),

              Center(
                child: Text(
                  "© 2024 LOOMCONTROL INDUSTRIAL SYSTEMS\nVERSION 4.2.0-ALPHA",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}