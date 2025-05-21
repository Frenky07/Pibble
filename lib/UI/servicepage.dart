import 'package:flutter/services.dart';
import 'package:pibble/UI/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pibble/UI/petservicepage.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  int _currentIndex = 1;
  late Future<List<Item>> _items;

  // Fetch data from Laravel API
  // Fetch data from local JSON file
  Future<List<Item>> fetchItems() async {
    final Uri url = Uri.parse(
        'http://localhost/flutter_api/services.php'); // Adjust to the location of your PHP file

    // Send GET request to the PHP endpoint
    final http.Response response = await http.get(url);

    // Check if the response is successful
    if (response.statusCode == 200) {
      // Decode the response body to JSON
      final List<dynamic> jsonData = json.decode(response.body);

      // Return the list of items
      return jsonData.map((data) => Item.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load items from the server');
    }
  }

  @override
  void initState() {
    super.initState();
    _items = fetchItems(); // Initialize future with fetched items
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F2F8), // Light blue background
      body: FutureBuilder<List<Item>>(
        future: _items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No services available'));
          } else {
            // Display items from the fetched API
            List<Item> items = snapshot.data!;
            return CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CustomSliverHeaderDelegate(
                    minHeight: 150.0,
                    maxHeight: 220.0,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Discover',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButton<String>(
                            value: 'Surabaya',
                            underline: Container(),
                            items: const [
                              DropdownMenuItem(
                                  value: 'Surabaya', child: Text('Surabaya')),
                            ],
                            onChanged: (value) {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          FilterChip(
                              label: const Text('Clinic'), onSelected: (_) {}),
                          const SizedBox(width: 10),
                          FilterChip(
                              label: const Text('Kucing'), onSelected: (_) {}),
                          const SizedBox(width: 10),
                          FilterChip(
                              label: const Text('Anjing'), onSelected: (_) {}),
                          const SizedBox(width: 10),
                          FilterChip(
                              label: const Icon(Icons.filter_list),
                              onSelected: (_) {}),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3 / 4,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to PetServicePage with the service ID
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetServicePage(
                                    serviceId:
                                        item.id, // Pass the actual item.id
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(15),
                                          bottom: Radius.circular(15),
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(item.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.star,
                                                color: Colors.amber),
                                            SizedBox(width: 1),
                                            Text(item.rating.toString()),
                                          ],
                                        ),
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          item.category,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ]),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class _CustomSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;

  _CustomSliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Text(
              "PIBBLE",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(221, 89, 89, 89),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari layanan untuk hewan peliharaanmu.',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class Item {
  final int id; // Add an ID field
  final String name;
  final double rating;
  final String category;
  final String imageUrl;

  Item({
    required this.id, // Make ID required
    required this.name,
    required this.rating,
    required this.category,
    required this.imageUrl,
  });

  // Factory method to create an Item from JSON data
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'], // Assign ID from JSON
      name: json['name'],
      rating: (json['rating'] is String)
          ? double.tryParse(json['rating']) ?? 0.0
          : json['rating'].toDouble(),
      category: json['category'],
      imageUrl: json['imageUrl'],
    );
  }
}
