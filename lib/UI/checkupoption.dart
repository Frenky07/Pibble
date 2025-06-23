import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pibble/UI/bookingpage.dart';

class CheckupOption extends StatelessWidget {
  final int serviceId;

  const CheckupOption({super.key, required this.serviceId});

  Future<List<Checkup>> fetchCheckups() async {
    final response = await http.get(
      Uri.parse(
          'http://localhost/flutter_api/get_checkups.php'), // ganti localhost jika perlu
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((item) => Checkup.fromJson(item))
            .toList();
      }
    }
    throw Exception('Gagal mengambil data checkup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F2F8),
      body: FutureBuilder<List<Checkup>>(
        future: fetchCheckups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Gagal memuat data checkup'));
          }

          final checkups = snapshot.data!;

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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 24.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final c = checkups[index];
                      return Column(
                        children: [
                          CheckupButton(
                            label: c.label,
                            description: c.description,
                            price: c.price,
                            serviceId: c.serviceId,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                    childCount: checkups.length,
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

class Checkup {
  final String label;
  final String description;
  final String price;
  final int serviceId;

  Checkup({
    required this.label,
    required this.description,
    required this.price,
    required this.serviceId,
  });

  factory Checkup.fromJson(Map<String, dynamic> json) {
    return Checkup(
      label: json['label'],
      description: json['description'],
      price: json['price'].toString(),
      serviceId: int.parse(json['services_id']), // ✅ FIXED
    );
  }
}

class CheckupButton extends StatefulWidget {
  final String label;
  final String description;
  final String price;
  final int serviceId;

  const CheckupButton({
    Key? key,
    required this.label,
    required this.description,
    required this.price,
    required this.serviceId,
  }) : super(key: key);

  @override
  _CheckupButtonState createState() => _CheckupButtonState();
}

class _CheckupButtonState extends State<CheckupButton> {
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
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                          label: widget.label, // ✅ kirim label
                          price: _formatPrice(widget
                              .price), // ✅ kirim harga yang sudah diformat
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
                  "Check Up",
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
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
