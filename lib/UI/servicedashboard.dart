import 'package:flutter/material.dart';
import 'package:pibble/Widgets/schedulecard.dart';
import 'package:pibble/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Servicedashboard extends StatefulWidget {
  @override
  _ServicedashboardState createState() => _ServicedashboardState();
}

class _ServicedashboardState extends State<Servicedashboard> {
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF7FD),
      body: DashboardContent(userId: userId),
    );
  }
}

class DashboardContent extends StatelessWidget {
  final int userId;

  const DashboardContent({super.key, required this.userId});

  Future<String> fetchPetName(int petId) async {
    const url = 'http://localhost/flutter_api/get_pets.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'pet_id': petId}),
    );

    if (response.statusCode == 200) {
      final String petName = json.decode(response.body);
      return petName;
    } else {
      throw Exception('Failed to load pet name');
    }
  }

  Future<List<dynamic>> fetchSchedules(int userId) async {
    const url = 'http://localhost/flutter_api/get_schedule_doctor.php';
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _CustomSliverHeaderDelegate(userId: userId),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Column(
                children: [
                  SizedBox(height: 15),
                  Text(
                    "Schedule Penyedia Jasa",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Add FutureBuilder to fetch schedules
                  FutureBuilder<List<dynamic>>(
                    future: fetchSchedules(userId),
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
                      }
                    },
                  ),
                ],
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
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 4),
            blurRadius: 8.0,
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
                  // Navigate to profile page
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.grey),
                ),
              ),
              Spacer(),
              const Text("PIBBLE SERVICES",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Spacer(),
              Icon(Icons.notifications, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 120.0;

  @override
  double get minExtent => 120.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
