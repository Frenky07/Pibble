import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pibble/UI/servicedashboard.dart';
import 'package:pibble/UI/signup.dart';
import 'package:pibble/user_provider.dart';
import 'dart:convert';
import 'dashboard.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'Pemilik Hewan'; // Default value for the dropdown

  Future<void> _login() async {
    String url;

    if (kIsWeb) {
      url = 'http://127.0.0.1/flutter_api/login.php';
    } else if (Platform.isAndroid) {
      url = 'http://10.0.2.2/flutter_api/login.php';
    } else {
      url = 'http://10.0.2.2/flutter_api/login.php';
    }

    final email = _emailController.text;
    final password = _passwordController.text;

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'email': email,
        'password': password,
        'role': _selectedRole, // Include selected role
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseData['message'] == 'Login successful') {
        // Save userId in UserProvider
        int userId = responseData[
            'user_id']; // This should be an int if it's coming as an int
        Provider.of<UserProvider>(context, listen: false).setUserId(userId);

        // Check if the user is a "Penyedia Jasa" but not a "doctor"
        if (_selectedRole == 'Penyedia Jasa' &&
            responseData['role'] != 'doctor') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Akun tidak memiliki izin')),
          );
        } else {
          // Navigate to the appropriate dashboard
          if (_selectedRole == 'Penyedia Jasa' &&
              responseData['role'] == 'doctor') {
            // Navigate to ServiceDashboardPage if user is a doctor
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Servicedashboard()),
            );
          } else {
            // Navigate to the regular DashboardPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Unable to connect to server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top teal section
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(35)),
                image: DecorationImage(
                  image: AssetImage('assets/images/dog_image.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Bottom section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 24),
                  // Dropdown for role selection
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRole = newValue!;
                        });
                      },
                      items: <String>['Pemilik Hewan', 'Penyedia Jasa']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      isExpanded: true,
                      underline: SizedBox(),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Email field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Password field
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 24),
                  // Login button
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 73, 200, 245),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Alternative method text
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.black26,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Gunakan metode lain',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.black26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Google login button
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 73, 200, 245),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: Image.asset('assets/images/google_logo.png',
                        height: 24),
                    label: const Text(
                      'Google Account',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Footer links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                          );
                        },
                        child: Text('Buat Akun Baru'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('Lupa Password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
