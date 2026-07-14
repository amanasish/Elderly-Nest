import 'package:flutter/material.dart';
import 'app_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    setState(() => isLoading = true);

    final url = Uri.parse('https://eldernest.onrender.com/api/userRegister');
    
    print("Sending POST request...");
    print("Name: ${nameController.text}, Email: ${emailController.text}");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final res = jsonDecode(response.body);

      if (response.statusCode == 200 && res['status'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['msg'])),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['msg'] ?? "Something went wrong")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to register. Check network or API.")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register', style: AppStyles.headingMedium),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppStyles.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/RegImg1.png',
                height: 180,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Text('Create an Account', style: AppStyles.headingLarge),
              SizedBox(height: 20),
  
              TextField(
                controller: nameController,
                decoration: AppStyles.textFieldDecoration.copyWith(labelText: 'Full Name'),
              ),
              SizedBox(height: 16),
  
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
  
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: AppStyles.elevatedButtonStyle,
                      onPressed: registerUser,
                      child: Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
