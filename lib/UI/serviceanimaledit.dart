import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:pibble/Widgets/animalcard.dart';
import 'package:pibble/user_provider.dart';
import 'package:provider/provider.dart';

class ServiceAnimalPage extends StatefulWidget {
  const ServiceAnimalPage({Key? key}) : super(key: key);

  @override
  _ServiceAnimalPageState createState() => _ServiceAnimalPageState();
}

class _ServiceAnimalPageState extends State<ServiceAnimalPage> {
  List<dynamic> _animals = [];
  List<int> _selectedIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    _loadData(userId);
  }

  Future<void> _loadData(int userId) async {
    final animalsResponse = await http.get(
      Uri.parse('http://localhost/flutter_api/get_all_animals.php'),
    );
    final selectedResponse = await http.post(
      Uri.parse(
          'http://localhost/flutter_api/get_service_selected_animals.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"user_id": userId}),
    );

    // 🟢 DEBUG: print exactly what comes back
    print('Selected response body: ${selectedResponse.body}');

    final decoded = json.decode(selectedResponse.body);

    setState(() {
      _animals = json.decode(animalsResponse.body);
      _selectedIds = (decoded as List).map((e) {
        print('Parsing element: $e (${e.runtimeType})'); // 🔍 see type
        return int.parse(e.toString());
      }).toList();
      _isLoading = false;
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _saveSelection() async {
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    final response = await http.post(
      Uri.parse('http://localhost/flutter_api/update_service_animals.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": userId,
        "animal_ids": _selectedIds,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
    }
  }

  Color _getColor(String color) {
    switch (color.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'pink':
        return Colors.pink;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'sound_detection_dog_barking':
        return Icons.pets;
      case 'raven':
        return Symbols.raven;
      case 'mouse':
        return Symbols.mouse;
      case 'cruelty_free':
        return Icons.cruelty_free;
      case 'waves':
        return Icons.waves;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF7FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text('Tambah Hewan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _animals.length,
                itemBuilder: (context, index) {
                  final animal = _animals[index];
                  final id = int.parse(animal['id'].toString());
                  final isSelected = _selectedIds.contains(id);

                  return GestureDetector(
                    onTap: () => _toggleSelection(id),
                    child: AnimalCard(
                      name: animal['name'],
                      backgroundColor: _getColor(animal['color']),
                      iconData: _getIcon(animal['icon']),
                      isSelected: isSelected,
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _saveSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF47C7F4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Simpan Pilihan'),
          ),
        ),
      ),
    );
  }
}
