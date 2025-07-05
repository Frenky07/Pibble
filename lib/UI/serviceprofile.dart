import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pibble/UI/login.dart';
import 'package:pibble/UI/petprofile.dart';
import 'package:pibble/UI/serviceedit.dart';
import 'package:pibble/Widgets/animalcard.dart';
import 'package:pibble/Widgets/petcard.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:pibble/user_provider.dart';
import 'package:provider/provider.dart';

class ServiceProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ServiceProfilePage> {
  List<dynamic> _animals = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _serviceName = '';
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    _fetchAnimals(userId);
    _fetchServiceInfo(userId);
  }

  void _fetchServiceInfo(int userId) async {
    try {
      const url = 'http://localhost/flutter_api/get_service_info.php';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"user_id": userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data');
        print('Parsed name: ${data['name']}');
        print('Parsed rating: ${data['rating']}');
        if (data['error'] == null) {
          setState(() {
            _serviceName = data['name'] ?? '';

            if (data['rating'] != null) {
              _rating = double.tryParse(data['rating'].toString()) ?? 0.0;
            } else {
              _rating = 0.0;
            }
          });
        }
      }
    } catch (e) {}
  }

  void _fetchAnimals(int userId) async {
    try {
      const url = 'http://localhost/flutter_api/get_animalcard.php';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"user_id": userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _animals = json.decode(response.body);
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
    }
  }

  Color _getColorFromName(String colorName) {
    Map<String, Color> colorMap = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'purple': Colors.purple,
      'orange': Colors.orange,
      'pink': Colors.pink,
      'brown': Colors.brown,
      'gray': Colors.grey,
      'black': Colors.black,
      'white': Colors.white,
      'teal': Colors.teal,
      'indigo': Colors.indigo,
      'amber': Colors.amber,
      'lime': Colors.lime,
      'cyan': Colors.cyan,
      'deepPurple': Colors.deepPurple,
      'lightBlue': Colors.lightBlue,
      'lightGreen': Colors.lightGreen,
      'blueGrey': Colors.blueGrey,
      'yellowAccent': Colors.yellowAccent,
    };

    return colorMap[colorName] ?? Colors.black; // Default to black if not found
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'sound_detection_dog_barking':
        return Symbols.sound_detection_dog_barking;
      case 'raven':
        return Symbols.raven;
      case 'mouse':
        return Symbols.mouse;
      case 'cruelty_free':
        return Symbols.cruelty_free;
      case 'waves':
        return Symbols.waves;
      default:
        return Symbols.help_outline;
    }
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
                        _serviceName.isNotEmpty ? _serviceName : '...',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _rating > 0 ? _rating.toStringAsFixed(1) : '-',
                          style: const TextStyle(
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
                    'Melayani Hewan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Loading or Error Handling
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _hasError
                          ? const Center(child: Text("Failed to load animals."))
                          : _animals.isNotEmpty
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: _animals.map((animal) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12.0),
                                        child: AnimalCard(
                                          name: animal['name'] ?? 'Unknown',
                                          backgroundColor: _getColorFromName(
                                              animal['color'] ?? 'Black'),
                                          iconData: _getIconFromName(
                                              animal['icon'] ?? ''),
                                          isSelected: false,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              : const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Text("No animals found."),
                                ),
                  SizedBox(height: 16),
                  // Options Section
                  Container(
                    color: Color(0xFFEEF7FD),
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ServiceEditPage()),
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
                                Icon(Symbols.border_color, color: Colors.grey),
                                SizedBox(width: 16),
                                Text('Kustomisasi',
                                    style: TextStyle(fontSize: 16)),
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
