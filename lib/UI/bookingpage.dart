import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pibble/Widgets/petcard.dart';
import 'package:pibble/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dashboard.dart'; // Import your Dashboard page

class BookingPage extends StatefulWidget {
  final int serviceId;
  final String label;
  final String price;

  const BookingPage({
    super.key,
    required this.serviceId,
    required this.label,
    required this.price,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedPet;
  List<Map<String, dynamic>> _pets = [];
  bool _isLoading = true;
  String? _waktu; // Store the fetched waktu

  @override
  void initState() {
    super.initState();
    _fetchPets();
    _fetchWaktu(); // Fetch waktu when the page loads
  }

  Future<void> _fetchPets() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    const apiUrl = "http://localhost/flutter_api/petcard.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _pets = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load pets: ${response.body}")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _fetchWaktu() async {
    const apiUrl = "http://localhost/flutter_api/get_waktu.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"service_id": widget.serviceId}),
      );

      print("Request Body: ${jsonEncode({
            "service_id": widget.serviceId
          })}"); // Debugging line

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _waktu = data['waktu']; // Store the fetched waktu
        });
      } else {
        throw Exception("Failed to fetch waktu: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDay == null || _selectedPet == null) {
      print("Required data is missing");
      return;
    }

    // Check if the selected date is before today
    if (_selectedDay!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a future date")),
      );
      return;
    }

    // Capture the required data
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final petId = _pets.firstWhere((pet) => pet['name'] == _selectedPet)['id'];

    // Prepare the data for the request
    final data = {
      "date": _selectedDay!.toIso8601String(),
      "user_id": userId,
      "pets_id": petId,
      "service_id": widget.serviceId,
    };

    // Print the data being sent
    print("Booking Data: $data");

    const apiUrl = "http://localhost/flutter_api/insert_schedule.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      // Print the response from the API
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final historyApiUrl ="http://localhost/flutter_api/insert_histories.php";

          final historyData = {
            "service_id": widget.serviceId,
            "price": int.parse(widget.price.replaceAll('.', '')),
            "pet_id": petId,
            "date": DateTime.now().toIso8601String().split('T').first,
            "label":widget.label,
          };

          await http.post(
            Uri.parse(historyApiUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(historyData),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Booking failed: ${responseData['message']}")),
          );
        }
      } else {
        throw Exception("Failed to book appointment");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F2F8),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _CustomSliverHeaderDelegate(
              minHeight: 120.0,
              maxHeight: 120.0,
            ),
          ),
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  "Pilih Jadwalmu",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Waktu",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    Text(
                      _waktu ?? "Loading...",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Pilih Hewan Peliharaanmu",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _pets.map((pet) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: 12.0), // spacing between cards
                              child: PetCard(
                                name: pet['name'],
                                age: pet['age'],
                                color: _getColorFromName(pet['color']),
                                onButtonTap: () {
                                  setState(() {
                                    _selectedPet = _selectedPet == pet['name']
                                        ? null
                                        : pet['name'];
                                  });
                                },
                                isSelected: _selectedPet == pet['name'],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                // const SizedBox(height: 24),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      "Rp ${widget.price}",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Booking",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ]),
            ),
          ),
        ],
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
            const SizedBox(height: 45),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context); // Navigate back
                  },
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Booking",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(221, 89, 89, 89),
                      ),
                    ),
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
