import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pibble/user_provider.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> histories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistories();
  }

  Future<void> fetchHistories() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    const url = 'http://localhost/flutter_api/get_histories.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          histories = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F2F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7F2F8),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: histories.length,
              itemBuilder: (context, index) {
                final item = histories[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.pinkAccent,
                                child: Icon(Icons.pets, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['service_name'] ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                  Text(
                                    item['date'] ?? '-',
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${item['label'] ?? '-'} - ${item['pet_name'] ?? '-'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Total biaya',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                          Text(
                            'Rp ${item['price']?.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF9CA3AF)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Beri ulasan dapat ',
                                  style: TextStyle(color: Color(0xFF374151)),
                                ),
                                const Text(
                                  'Paw-Poin',
                                  style: TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => const Icon(
                                      Icons.star,
                                      size: 20,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
