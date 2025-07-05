import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pibble/UI/serviceprofile.dart';
import 'package:pibble/Widgets/schedulecard.dart';
import 'package:pibble/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pibble/UI/userprofile.dart';
import 'package:table_calendar/table_calendar.dart';

class Servicedashboard extends StatefulWidget {
  const Servicedashboard({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<Servicedashboard> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    _pages = [
      DashboardContent(userId: userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF7FD),
      body: _pages[_currentIndex],
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
  late Future<List<dynamic>> _schedules;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _scheduleDays = {};

  @override
  void initState() {
    super.initState();
    _schedules = fetchSchedules(widget.userId);
  }

  Future<List<dynamic>> fetchSchedules(int userId) async {
    const url = 'http://localhost/flutter_api/get_schedule_services.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> scheduleList = json.decode(response.body);
      if (scheduleList.isEmpty) return [];

      _scheduleDays = scheduleList
          .map((s) {
            final dateStr = s['date'] ?? '';
            return DateTime.tryParse(dateStr)?.toLocal();
          })
          .whereType<DateTime>()
          .toSet();

      return scheduleList;
    } else {
      return [
        {"error": "Failed to load schedules. Please try again later."}
      ];
    }
  }

  Widget _buildDot(Color color) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
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
              const SizedBox(
                height: 16,
              ),
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
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final isToday = isSameDay(date, DateTime.now());
                    final hasSchedule =
                        _scheduleDays.any((d) => isSameDay(d, date));

                    if (isToday && hasSchedule) {
                      return _buildDot(Colors.purple);
                    } else if (hasSchedule) {
                      return _buildDot(Colors.blue);
                    } else if (isToday) {
                      return _buildDot(Colors.red);
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jadwal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<dynamic>>(
                future: _schedules,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No schedules available.'));
                  } else {
                    final schedules = snapshot.data!;
                    return Column(
                      children: schedules.map((schedule) {
                        final petName =
                            schedule['pet_name'] ?? 'Tidak diketahui';
                        final serviceName =
                            schedule['service_name'] ?? 'Layanan';
                        final dateStr = schedule['date'] ??
                            DateTime.now().toIso8601String();
                        final date =
                            DateTime.tryParse(dateStr) ?? DateTime.now();
                        final formattedDate =
                            '${date.day}/${date.month}/${date.year}';
                        final label = schedule['label'] ?? '';

                        return ScheduleCard(
                          day: formattedDate,
                          petName: petName,
                          serviceName: serviceName,
                          label: label,
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
            ]),
          ),
        ),
      ],
    );
  }
}

class _CustomSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int userId;
  late final Future<Map<String, dynamic>> _pointsFuture;

  _CustomSliverHeaderDelegate({required this.userId}) {
    _pointsFuture = fetchPoints(userId);
  }

  Future<Map<String, dynamic>> fetchPoints(int userId) async {
    const url = 'http://localhost/flutter_api/get_pawspoints.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('error')) {
        return {"error": data['error']};
      }
      return data;
    } else {
      return {"error": "Failed to load points. Please try again later."};
    }
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ServiceProfilePage()),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
              const Spacer(),
              const Text(
                "PIBBLE SERVICE",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.notifications, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Selamat datang kembali",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text("User $userId",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 150.0;

  @override
  double get minExtent => 150.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
