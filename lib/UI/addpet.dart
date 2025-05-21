import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math'; // For generating random numbers

import 'package:pibble/UI/dashboard.dart';
import 'package:pibble/user_provider.dart';
import 'package:provider/provider.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  _AddPetPageState createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  List<String> jenisHewan = [];
  String? selectedJenisHewan;
  String? selectedJenisKelamin = "Laki Laki";
  String? selectedUmurHewan = "dewasa";
  TextEditingController nameController = TextEditingController();
  TextEditingController beratController = TextEditingController();

  // List of color names with their corresponding Colors
  final Map<String, Color> colorOptions = {
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

  String selectedColor = 'green'; // Default color

  @override
  void initState() {
    super.initState();
    _fetchJenisHewan();
    _randomizeColor(); // Call randomize color on page load
  }

  // Function to randomly pick a color from the list
  void _randomizeColor() {
    final random = Random();
    List<String> colorKeys = colorOptions.keys.toList();
    setState(() {
      selectedColor = colorKeys[random.nextInt(colorKeys.length)];
    });
  }

  Future<String?> _getAnimalIdFromName(String animalName) async {
    const apiUrl = "http://localhost/flutter_api/get_animal_id_from_name.php";

    try {
      // Use the query parameter format for GET request
      final response =
          await http.get(Uri.parse('$apiUrl?animal_name=$animalName'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);

        // Assuming the response contains an "id" field
        if (data['animal_id'] != null) {
          return data['animal_id'].toString(); // Return the id as a string
        } else {
          print("Animal not found");
          return null;
        }
      } else {
        print("Failed to fetch animal: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching animal: $e");
      return null;
    }
  }

  Future<void> _fetchJenisHewan() async {
    final response = await http
        .get(Uri.parse('http://localhost/flutter_api/get_animals.php'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        jenisHewan = data.cast<String>();
      });
    } else {
      throw Exception('Failed to load animals');
    }
  }

  Future<void> _addPet() async {
    // Replace with the actual user ID from the user session or user provider
    int? getUserId(BuildContext context) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      return userProvider.userId; // Access the userId
    }

    int? userId = getUserId(context);
    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    // Get the animal_id from the selected animal name
    var animalId = await _getAnimalIdFromName(selectedJenisHewan!);

    if (animalId != null) {
      final response = await http.post(
        Uri.parse('http://localhost/flutter_api/insert_pets.php'),
        body: {
          'name': nameController.text,
          'age': selectedUmurHewan!,
          'color': selectedColor, // Send the random color here
          'user_id': userId,
          'berat': beratController.text,
          'animal_id': animalId, // Use the animal_id fetched
          'jeniskelamin': selectedJenisKelamin!,
        },
      );

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result['message'])));

          // Redirect to Dashboard after adding the pet
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const DashboardPage()), // Or use your existing DashboardPage
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result['message'])));
        }
      } else {
        throw Exception('Failed to add pet');
      }
    } else {
      throw Exception('Please fill all boc');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Hewan"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/camera.png',
                  height: 200,
                  width: 200,
                ),
              ),
              const SizedBox(height: 20),
              buildSubtitle("Jenis Hewan"),
              buildDropdownField("Pilih jenis Hewan Peliharanmu", jenisHewan,
                  (value) {
                setState(() {
                  selectedJenisHewan = value;
                });
              }),
              const SizedBox(height: 20),
              buildSubtitle("Jenis Kelamin"),
              buildDropdownField("Pilih kelamin Hewan Peliharanmu",
                  ["Laki Laki", "Perempuan", "Lainnya"], (value) {
                setState(() {
                  selectedJenisKelamin = value;
                });
              }),
              const SizedBox(height: 20),
              buildSubtitle("Nama Hewan"),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "Nama Hewan Peliharanmu",
                  hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 193, 193, 193)),
                ),
              ),
              const SizedBox(height: 20),
              buildSubtitle("Umur Hewan"),
              buildDropdownField("Umur Hewan Peliharanmu", ["dewasa", "anak"],
                  (value) {
                setState(() {
                  selectedUmurHewan = value;
                });
              }),
              const SizedBox(height: 20),
              buildSubtitle("Berat Hewan"),
              TextField(
                controller: beratController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: "Berat Hewan Peliharanmu",
                  hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 193, 193, 193)),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _addPet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Tambahkan",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSubtitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget buildDropdownField(
      String hintText, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: const Color.fromARGB(255, 193, 193, 193)),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      value: hintText == "Pilih jenis Hewan Peliharanmu"
          ? selectedJenisHewan
          : hintText == "Pilih kelamin Hewan Peliharanmu"
              ? selectedJenisKelamin
              : selectedUmurHewan,
    );
  }
}
