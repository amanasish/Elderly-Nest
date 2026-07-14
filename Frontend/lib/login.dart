import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_styles.dart';
import 'main.dart'; // or the file where BottomTabScreen is defined
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    final url = Uri.parse('https://eldernest.onrender.com/api/userLogin');

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: AppStyles.headingMedium),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: AppStyles.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please Login', style: AppStyles.headingLarge),
            SizedBox(height: 24),

            TextField(
              controller: emailController,
              decoration: AppStyles.textFieldDecoration.copyWith(labelText: 'Email'),
            ),
            SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: AppStyles.textFieldDecoration.copyWith(labelText: 'Password'),
            ),
            SizedBox(height: 24),

            ElevatedButton(
              style: AppStyles.elevatedButtonStyle,
              onPressed: loginUser,
              child: Text('Login'),
            ),
            SizedBox(height: 16),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
