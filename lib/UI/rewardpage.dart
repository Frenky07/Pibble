import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pibble/UI/memberpage.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class Rewardpage extends StatefulWidget {
  const Rewardpage({super.key});

  @override
  _RewardPageState createState() => _RewardPageState();
}

class _RewardPageState extends State<Rewardpage> {
  int _currentIndex = 2;

  int pawspoints = 0;
  int memberPoints = 0;
  bool loading = true;
  String errorMessage = '';

  final List<Voucher> vouchers = [
    Voucher(
        image: 'assets/images/voucher1.png',
        title: 'Voucher Pawntastic Deal',
        points: 30),
    Voucher(
        image: 'assets/images/voucher2.png',
        title: 'Voucher Groom & Glow',
        points: 30),
    Voucher(
        image: 'assets/images/voucher3.png',
        title: 'Voucher Purrfect Promo',
        points: 30),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserPoints(1); // pass the user_id dynamically here
  }

  Future<void> fetchUserPoints(int userId) async {
    final url = Uri.parse('http://localhost/flutter_api/get_pawspoints.php'); // Replace with your PHP endpoint URL

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pawspoints = data['pawspoints'] ?? 0;
          memberPoints = data['member_points'] ?? 0;
          loading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load points: ${response.reasonPhrase}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Gradient Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Group_77.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Symbols.award_star_sharp,
                      color: Colors.amber,
                      size: 64,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'BUDDY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 16),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MemberPage()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Row(
                                children: [
                                  Text(
                                    '$pawspoints',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Paw-Poin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: Colors.white24,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.yellow),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Champ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '3.962 XP lagi jadi Champ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Voucher Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: vouchers.length,
              itemBuilder: (context, index) {
                final voucher = vouchers[index];
                return VoucherCard(
                  image: voucher.image,
                  title: voucher.title,
                  points: voucher.points,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VoucherCard extends StatelessWidget {
  final String image;
  final String title;
  final int points;

  const VoucherCard(
      {required this.image, required this.title, required this.points});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://via.placeholder.com/80',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$points Poin',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

class Voucher {
  final String image;
  final String title;
  final int points;

  Voucher({required this.image, required this.title, required this.points});
}
