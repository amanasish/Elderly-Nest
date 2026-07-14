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

    final url = Uri.parse('https://elderly-care-backend-giv2.onrender.com/api/userRegister');
    
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
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text('Register', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/icons/RegImg1.png',
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                shadowColor: Colors.teal.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create an Account',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        decoration: AppStyles.textFieldDecoration.copyWith(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person, color: Colors.teal),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: AppStyles.textFieldDecoration.copyWith(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Colors.teal),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: AppStyles.textFieldDecoration.copyWith(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Colors.teal),
                        ),
                      ),
                      SizedBox(height: 24),
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              onPressed: registerUser,
                              child: Text('Register'),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
