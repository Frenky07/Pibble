import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pibble/Widgets/schedulecard.dart';

class PetProfilePage extends StatefulWidget {
  final int pet_id;
  final String petName;
  final String age;
  final String gender;
  final int weight;

  const PetProfilePage({
    super.key,
    required this.pet_id,
    required this.petName,
    required this.age,
    required this.gender,
    required this.weight,
  });

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  late Future<List<Map<String, String>>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    print("initState - pet_id: ${widget.pet_id}");
    print("initState - petName: ${widget.petName}");
    print("initState - age: ${widget.age}");
    print("initState - gender: ${widget.gender}");
    print("initState - weight: ${widget.weight}");
    _scheduleFuture = fetchSchedule(widget.pet_id);
  }

  Future<List<Map<String, String>>> fetchSchedule(int petId) async {
    try {
      print("fetchSchedule - sending request for pet_id: $petId");
      final response = await http.post(
        Uri.parse('http://localhost/flutter_api/get_pet_schedule.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pet_id': petId}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Decoded data: $data");

        if (data['status'] == 'success' && data['schedules'] is List) {
          final parsed = (data['schedules'] as List).map<Map<String, String>>((item) => {
                'date': item['date'].toString(),
                'task': item['task'].toString(),
              }).toList();
          print("Parsed schedule: $parsed");
          return parsed;
        }
      }
      return [];
    } catch (e) {
      print("Fetch schedule error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Pet Image
          Container(
            height: 200,
            color: Colors.brown,
            child: Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage('https://via.placeholder.com/200'),
                radius: 80,
              ),
            ),
          ),

          // Pet Details Card
          Container(
            transform: Matrix4.translationValues(0.0, -40.0, 0.0),
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(widget.petName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(widget.age, style: TextStyle(fontSize: 18, color: Colors.grey)),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.pets, color: Colors.pink),
                            SizedBox(height: 4),
                            Text('Kelamin'),
                            Text(widget.gender, style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.monitor_weight, color: Colors.blue),
                            SizedBox(height: 4),
                            Text('Berat Badan'),
                            Text("${widget.weight} kg", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.cake, color: Colors.blue),
                            SizedBox(height: 4),
                            Text('Umur'),
                            Text(widget.age, style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Jadwal Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Jadwal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: Text('Tambahkan', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),

          // Schedule List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<List<Map<String, String>>>(
                future: _scheduleFuture,
                builder: (context, snapshot) {
                  print("FutureBuilder snapshot: ${snapshot.connectionState}");
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Failed to load schedule: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No schedule available'));
                  } else {
                    final schedules = snapshot.data!;
                    return ListView.builder(
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final item = schedules[index];
                        return ScheduleCard(
                          serviceName: item['service_name'] ?? '',
                          day: item['date'] ?? '',
                          petName: widget.petName,
                          label: item['task'] ?? '',
                          color: Color.fromARGB(255, 73, 200, 245),
                          onTap: () => print('Tapped ${item['task']}'),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
