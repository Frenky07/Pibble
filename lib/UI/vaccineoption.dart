import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pibble/UI/bookingpage.dart';

class VaccineOption extends StatelessWidget {
  const VaccineOption({super.key});

  Future<List<Vaccine>> fetchVaccines() async {
    final response = await http.get(Uri.parse('http://localhost/flutter_api/get_vaccines.php'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success']) {
        return (jsonData['data'] as List)
            .map((item) => Vaccine.fromJson(item))
            .toList();
      } else {
        throw Exception("Gagal mengambil data");
      }
    } else {
      throw Exception("Koneksi gagal");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F2F8),
      body: FutureBuilder<List<Vaccine>>(
        future: fetchVaccines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Gagal mengambil data vaksin"));
          }

          final vaccines = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _CustomSliverHeaderDelegate(
                  minHeight: 120.0,
                  maxHeight: 120.0,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final v = vaccines[index];
                      return Column(
                        children: [
                          VaccineButton(
                            label: v.label,
                            description: v.description,
                            price: v.price,
                            serviceId: v.serviceId,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                    childCount: vaccines.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Vaccine {
  final String label;
  final String description;
  final String price;
  final int serviceId;

  Vaccine({
    required this.label,
    required this.description,
    required this.price,
    required this.serviceId,
  });

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      label: json['label'],
      description: json['description'],
      price: json['price'].toString(),
      serviceId: int.parse(json['services_id']),
    );
  }
}

class VaccineButton extends StatefulWidget {
  final String label;
  final String description;
  final String price;
  final int serviceId;

  const VaccineButton({
    Key? key,
    required this.label,
    required this.description,
    required this.price,
    required this.serviceId,
  }) : super(key: key);

  @override
  _VaccineButtonState createState() => _VaccineButtonState();
}

class _VaccineButtonState extends State<VaccineButton> {
  bool _isExpanded = false;

  String _formatPrice(String price) {
    try {
      final number = int.parse(price.replaceAll('.', ''));
      return number.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]}.',
          );
    } catch (_) {
      return price;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Icon(
                _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Keterangan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Harga",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Rp ${_formatPrice(widget.price)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingPage(
                          serviceId: widget.serviceId,
                          label: widget.label,
                          price: _formatPrice(widget.price),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Pilih",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
            const SizedBox(height: 45),
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const Text(
                  "Vaksin",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(221, 89, 89, 89),
                  ),
                ),
              ],
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
