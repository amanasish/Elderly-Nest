import 'package:flutter/material.dart';
import 'app_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
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

    final url = Uri.parse('${Config.baseUrl}/userRegister');
    
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
      backgroundColor: Color(0xFF1C1C23),
      appBar: AppBar(
        title: Text('Register', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
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
                    'assets/icons/RegImg1.png',
                    height: 160,
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
                        'Create an Account',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Join ElderNest today',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),
                      TextField(
                        controller: nameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.person_rounded, color: Colors.grey.shade500),
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
                              onPressed: registerUser,
                              child: Text('Register'),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
