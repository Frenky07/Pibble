import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pibble/UI/addpet.dart';
import 'package:pibble/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:pibble/Widgets/petcard.dart';
import 'package:pibble/Widgets/schedulecard.dart';
import 'package:pibble/UI/petprofile.dart';
import 'package:pibble/UI/rewardpage.dart';
import 'package:pibble/UI/servicepage.dart';
import 'package:pibble/UI/userprofile.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    _pages = [
      DashboardContent(userId: userId), // Pass userId to DashboardContent
      const ServicePage(),
      const Rewardpage(),
      const Rewardpage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF7FD),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.grid_view,
              color: _currentIndex == 0 ? Colors.teal : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.pets,
              color: _currentIndex == 1 ? Colors.teal : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Symbols.featured_seasonal_and_gifts,
              color: _currentIndex == 2 ? Colors.teal : Colors.grey,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.redeem,
              color: _currentIndex == 2 ? Colors.teal : Colors.grey,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  final int userId;

  const DashboardContent({super.key, required this.userId});

  @override
  _DashboardContentState createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late Future<List<dynamic>> _pets;
  late Future<List<dynamic>> _schedules;

  // Fetch pets from the API
  Future<List<dynamic>> fetchPets(int userId) async {
    const url = 'http://localhost/flutter_api/petcard.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> petList = json.decode(response.body);
      return petList.isEmpty
          ? []
          : petList; // Return an empty list if no pets found
    } else {
      return [
        {"error": "Failed to load pets. Please try again later."}
      ];
    }
  }

  // Fetch schedules from the API
  Future<List<dynamic>> fetchSchedules(int userId) async {
    const url = 'http://localhost/flutter_api/get_schedule.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> scheduleList = json.decode(response.body);
      return scheduleList.isEmpty
          ? []
          : scheduleList; // Return an empty list if no schedules found
    } else {
      return [
        {"error": "Failed to load schedules. Please try again later."}
      ];
    }
  }

  Future<void> deletePassedSchedules() async {
    final response = await http
        .get(Uri.parse('http://localhost/flutter_api/delete_schedule.php'));

    if (response.statusCode == 200) {
      print('Schedules deleted: ${response.body}');
      fetchSchedules(widget.userId); // Refresh the schedule list after deletion
    } else {
      print('Failed to delete schedules');
    }
  }

  @override
  void initState() {
    super.initState();
    _pets = fetchPets(widget.userId);
    _schedules =
        fetchSchedules(widget.userId); // Ensure _schedules is initialized
    startAutoDelete();
  }

  // Set up periodic auto-deletion (every 1 hour in this example)
  void startAutoDelete() {
    Timer.periodic(Duration(hours: 1), (timer) {
      deletePassedSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _CustomSliverHeaderDelegate(userId: widget.userId),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Title with "Tambahkan" button
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Peliharaanmu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddPetPage(),
                        ),
                      );
                    },
                    child: const Text('Tambahkan'),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // FutureBuilder to display pets
              FutureBuilder<List<dynamic>>(
                future: _pets,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No pet available.'));
                  } else {
                    final pets = snapshot.data!;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: pets.map((pet) {
                          return PetCard(
                            name: pet['name'] ?? 'Pet Name',
                            age: pet['age'] ?? 'Pet Age',
                            color: _getColorFromName(pet['color'] ?? 'Black'),
                            onButtonTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetProfilePage(
                                    petName: pet['name'] ?? 'Pet Name',
                                    age: pet['age'] ?? 'Pet Age',
                                    gender: pet['jeniskelamin'] ?? 'Unknown',
                                    weight: pet['berat'] ?? 00,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 24),

              // Schedule section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jadwal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Notify DashboardPage to switch to the Service tab
                      final parentState = context
                          .findAncestorStateOfType<_DashboardPageState>();
                      parentState?.setState(() {
                        parentState._currentIndex =
                            1; // Switch to the Service tab
                      });
                    },
                    child: const Text('Tambahkan'),
                  ),
                ],
              ),

              // FutureBuilder to display schedules dynamically
              FutureBuilder<List<dynamic>>(
                future: _schedules,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No schedules available.'));
                  } else {
                    final schedules = snapshot.data!;
                    return Column(
                      children: schedules.map((schedule) {
                        final petName = schedule['pet_name'];
                        final serviceName = schedule['service_name'];
                        final date = DateTime.parse(schedule['date']);
                        final formattedDate =
                            '${date.day}/${date.month}/${date.year}';
                        final formattedTime =
                            '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                        final waktu = schedule['waktu'];

                        return Column(
                          children: schedules.map((schedule) {
                            final petName = schedule['pet_name'];
                            final serviceName = schedule['service_name'];
                            final date = DateTime.parse(schedule['date']);
                            final formattedDate =
                                '${date.day}/${date.month}/${date.year}';
                            final formattedTime =
                                '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                            final waktu = schedule['waktu'];

                            return ScheduleCard(
                              time: schedule['waktu'],
                              day: formattedDate,
                              petName: petName,
                              task: serviceName,
                              color: const Color.fromARGB(255, 73, 200, 245),
                              onTap: () {
                                print('ScheduleCard tapped!');
                              },
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _CustomSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int userId;

  _CustomSliverHeaderDelegate({required this.userId});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Slight shadow color
            offset: Offset(0, 4), // Offset downwards
            blurRadius: 8.0, // Blur effect for the shadow
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 32.0,
        right: 32.0,
        bottom: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.grey),
                ),
              ),
              Spacer(),
              // "PIBBLE" text
              const Text(
                "PIBBLE",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              // Notification icon
              Icon(Icons.notifications, color: Colors.grey),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              // Welcome message and user info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selamat datang kembali",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    "User $userId",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Spacer(),
              // Points container
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 45, 161, 255),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "Poin",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      "1500",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 200.0;

  @override
  double get minExtent => 200.0;

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
