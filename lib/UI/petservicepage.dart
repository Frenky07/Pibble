import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pibble/UI/checkupoption.dart';
import 'dart:convert';

import 'package:pibble/UI/vaccineoption.dart';

class PetServicePage extends StatefulWidget {
  final int serviceId;
  const PetServicePage({super.key, required this.serviceId});

  @override
  _PetServicePageState createState() => _PetServicePageState();
}

class _PetServicePageState extends State<PetServicePage> {
  late Future<Map<String, dynamic>> clinicData;
  bool _isExpanded = false; // Track the expanded state

  @override
  void initState() {
    super.initState();
    clinicData = fetchClinicData(widget.serviceId);
  }

  Future<Map<String, dynamic>> fetchClinicData(int serviceId) async {
    final response = await http.get(Uri.parse(
        'http://localhost/flutter_api/services_animal.php?serviceId=$serviceId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load clinic data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<Map<String, dynamic>>(
        future: clinicData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data found'));
          }

          var clinic = snapshot.data!;
          var clinicName = clinic['name'] ?? 'Unknown Clinic';
          var animals = clinic['animals'] ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Image Section
                Stack(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/vet_clinic.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),

                // Clinic Info in Rounded Container
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(blurRadius: 8, color: Colors.grey)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              clinicName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(clinic['rating'].toString(),
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        if (_isExpanded) ...[
                          SizedBox(height: 8),
                          Text('Alamat: ${clinic['alamat']}',
                              style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Waktu: ${clinic['waktu']}',
                              style: TextStyle(fontSize: 16)),
                        ],
                        IconButton(
                          icon: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Serving Animals Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Melayani Hewan',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('Tampilkan lebih',
                          style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),

                // Animals List
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: animals.map<Widget>((animal) {
                      return _buildAnimalIcon(
                        animal['icon'],
                        animal['name'],
                        getColorFromName(animal['color']),
                      );
                    }).toList(),
                  ),
                ),

                // Services Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Layanan',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        _buildServiceButton(
                          'Check Up',
                          Colors.blue,
                          context,
                          () => CheckupOption(serviceId: widget.serviceId),
                        ),
                        SizedBox(height: 16),
                        _buildServiceButton(
                          'Vaksin Hewan',
                          Colors.red,
                          context,
                          () => VaccineOption(),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimalIcon(String iconName, String label, Color color) {
    IconData icon = _getIcon(iconName);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'sound_detection_dog_barking':
        return Icons.pets;
      case 'raven':
        return Icons.account_tree;
      case 'mouse':
        return Icons.mouse;
      case 'cruelty_free':
        return Icons.accessibility_new;
      case 'waves':
        return Icons.waves;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildServiceButton(String label, Color color, BuildContext context,
      [Widget Function()? destinationBuilder]) {
    return GestureDetector(
      onTap: () {
        if (destinationBuilder != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationBuilder()),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Map<String, String> colorMap = {
    'blue': '0xff0000FF',
    'green': '0xff008000',
    'red': '0xffFF0000',
    'yellow': '0xffFFFF00',
    'pink': '0xffFFC0CB',
    'orange': '0xffFFA500',
    'black': '0xff000000',
    'white': '0xffFFFFFF',
  };

  Color getColorFromName(String colorName) {
    String colorHex = colorMap[colorName.toLowerCase()] ?? '0xff000000';
    return Color(int.parse(colorHex));
  }
}
