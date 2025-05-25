import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pibble/UI/login.dart';
import 'package:pibble/UI/petprofile.dart';
import 'package:pibble/Widgets/petcard.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:pibble/user_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<dynamic> _pets = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    final String apiUrl =
        "http://localhost/flutter_api/petcard.php"; // Replace with your API URL
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final Map<String, dynamic> requestBody = {
      "user_id": userId
    }; // Example user_id

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> pets = jsonDecode(response.body);
        setState(() {
          _pets = pets;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print("Error fetching pets: $e");
    }
  }

  Color _getColorFromName(String colorName) {
    Map<String, Color> colorMap = {
      'Red': Colors.red,
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Yellow': Colors.yellow,
      'Purple': Colors.purple,
      'Orange': Colors.orange,
      'Pink': Colors.pink,
      'Brown': Colors.brown,
      'Gray': Colors.grey,
      'Black': Colors.black,
      'White': Colors.white,
      'Teal': Colors.teal,
      'Indigo': Colors.indigo,
      'Amber': Colors.amber,
      'Lime': Colors.lime,
      'Cyan': Colors.cyan,
      'DeepPurple': Colors.deepPurple,
      'LightBlue': Colors.lightBlue,
      'LightGreen': Colors.lightGreen,
      'BlueGrey': Colors.blueGrey,
      'YellowAccent': Colors.yellowAccent,
    };

    return colorMap[colorName] ?? Colors.black; // Default to black if not found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEF7FD),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Top Blue Background
                Container(
                  height: MediaQuery.of(context).size.height * 0.42,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/header.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Profile Info
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // Back Button
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: BackButton(),
                        ),
                      ),
                      // Profile Picture
                      CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            NetworkImage('https://via.placeholder.com/150'),
                      ),
                      SizedBox(height: 16),
                      // User Name
                      Text(
                        'Augustine',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Buddy Label
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Buddy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF47C7F4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Your Pets Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Peliharaanmu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Loading or Error Handling
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _hasError
                          ? Center(child: Text("Failed to load pets."))
                          : _pets.isNotEmpty
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: _pets.map((pet) {
                                      return PetCard(
                                        name: pet['name'] ?? 'Pet Name',
                                        age: pet['age'] ?? 'Pet Age',
                                        color: _getColorFromName(
                                            pet['color'] ?? 'Black'),
                                        onButtonTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PetProfilePage(
                                                petName:
                                                    pet['name'] ?? 'Pet Name',
                                                age: pet['age'] ?? 'Pet Age',
                                                gender: pet['jeniskelamin'] ??
                                                    'Unknown',
                                                weight: pet['berat'] ?? 00,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0),
                                  child: Text("No pets found."),
                                ),
                  SizedBox(height: 16),
                  // Options Section
                  Container(
                    color: Color(0xFFEEF7FD),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.settings, color: Colors.grey),
                                SizedBox(width: 16),
                                Text('Opsi', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.help_outline, color: Colors.grey),
                                SizedBox(width: 16),
                                Text('Bantuan', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            // Reset userId to 0 in UserProvider
                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);
                            userProvider.setUserId(0); // Reset the userId

                            // Navigate to login page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LoginPage()), // Replace ProfilePage with LoginPage
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Symbols.door_open, color: Colors.red),
                                SizedBox(width: 16),
                                Text(
                                  'Log Out',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
