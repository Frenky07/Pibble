import 'package:pibble/Widgets/schedulecard.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class PetProfilePage extends StatelessWidget {
  final String petName;
  final String age;
  final String gender;
  final int weight;

  const PetProfilePage({
    super.key,
    required this.petName,
    required this.age,
    required this.gender,
    required this.weight,
  });

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
          // Header with pet image
          Container(
            height: 200,
            color: Colors.brown,
            child: Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/200', // Replace with the actual image
                ),
                radius: 80,
              ),
            ),
          ),
          // Pet details
          Container(
            transform: Matrix4.translationValues(0.0, -40.0, 0.0),
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Text(
                          petName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          age,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.female, color: Colors.pink),
                            SizedBox(height: 4),
                            Text('Kelamin'),
                            Text(
                              gender,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Symbols.exercise, color: Colors.blue),
                            SizedBox(height: 4),
                            Text('Berat Badan'),
                            Text(
                              "$weight kg",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Symbols.pet_supplies, color: Colors.blue),
                            SizedBox(height: 4),
                            Text('Umur'),
                            Text(
                              age,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Schedule section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jadwal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Tambahkan',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Schedule cards
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: ListView(
                children: [
                  ScheduleCard(
                    day: "Besok",
                    time: '10:00',
                    petName: 'Lil Bro',
                    task: 'Vaksin rutin',
                    color: Color.fromARGB(255, 73, 200, 245),
                    onTap: () {
                      print('ScheduleCard tapped!');
                    },
                  ),
                  ScheduleCard(
                    day: "31/12/2025",
                    time: '13:00',
                    petName: 'Lil Bro',
                    task: 'Vaksin rutin',
                    color: Color.fromARGB(255, 73, 200, 245),
                    onTap: () {
                      print('ScheduleCard tapped!');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
