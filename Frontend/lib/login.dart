import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_styles.dart';
import 'main.dart'; // or the file where BottomTabScreen is defined
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() => isLoading = true);
    final url = Uri.parse('${Config.baseUrl}/userLogin');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ Store uniqueCode using SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        //await prefs.setString('uniqueCode', jsonData['data']['uniqueCode']);


        ///
        await prefs.setString('name', jsonData['data']['name']);
        await prefs.setString('email', jsonData['data']['email']);
        await prefs.setString('uniqueCode', jsonData['data']['uniqueCode']);
        await prefs.setString('userId', jsonData['data']['_id']);


        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonData['message'] ?? 'Login successful')),
        );

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomTabScreen(showWelcome: true),
          ),
        );
      }

      else {
        // Failed login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonData['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C23),
      appBar: AppBar(
        title: Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: Offset(0, 10))
                  ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/icons/LogImg1.png',
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2B2B36),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: Offset(0, 5))
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please login to continue',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),
                      TextField(
                        controller: emailController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.email_rounded, color: Colors.grey.shade500),
                          fillColor: Color(0xFF1C1C23),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.lock_rounded, color: Colors.grey.shade500),
                          fillColor: Color(0xFF1C1C23),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        ),
                      ),
                      SizedBox(height: 32),
                      isLoading
                          ? Center(child: CircularProgressIndicator(color: Color(0xFF6F51FF)))
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF6F51FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                elevation: 10,
                                shadowColor: Color(0xFF6F51FF).withOpacity(0.5)
                              ),
                              onPressed: loginUser,
                              child: Text('Login'),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    children: [
                      TextSpan(
                        text: "Register",
                        style: TextStyle(color: Color(0xFF6F51FF), fontWeight: FontWeight.bold, fontSize: 16)
                      )
                    ]
                  )
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
