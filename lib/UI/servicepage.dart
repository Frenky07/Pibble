import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pibble/UI/petservicepage.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  late Future<List<ServiceItem>> _futureItems;

  @override
  void initState() {
    super.initState();
    _futureItems = fetchServiceItems();
  }

  Future<List<ServiceItem>> fetchServiceItems() async {
    final url = Uri.parse('http://localhost/flutter_api/services.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => ServiceItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F2F8),
      body: FutureBuilder<List<ServiceItem>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No services available.'));
          }

          final items = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _CustomHeader(minHeight: 150, maxHeight: 220),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              value: 'Surabaya',
                              child: Text('Surabaya'),
                            ),
                          ],
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      children: [
                        FilterChip(label: const Text('Clinic'), onSelected: (_) {}),
                        FilterChip(label: const Text('Kucing'), onSelected: (_) {}),
                        FilterChip(label: const Text('Anjing'), onSelected: (_) {}),
                        FilterChip(label: const Icon(Icons.filter_list), onSelected: (_) {}),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: items.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3 / 4,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return GestureDetector(
                          onTap: () {
                            print('Tapped service ID: ${item.id}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PetServicePage(serviceId: item.id),
                              ),
                            );
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
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
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(item.rating.toString()),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        item.category,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CustomHeader extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;

  _CustomHeader({required this.minHeight, required this.maxHeight});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 15),
            const Text(
              "PIBBLE",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(221, 89, 89, 89),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari layanan untuk hewan peliharaanmu.',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Color(0xFFF0F0F0),
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
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

class ServiceItem {
  final int id;
  final String name;
  final double rating;
  final String category;
  final String imageUrl;

  ServiceItem({
    required this.id,
    required this.name,
    required this.rating,
    required this.category,
    required this.imageUrl,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      rating: (json['rating'] is String)
          ? double.tryParse(json['rating']) ?? 0.0
          : (json['rating'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
