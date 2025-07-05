import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pibble/UI/servicedashboard.dart';

class ServiceEditPage extends StatefulWidget {
  const ServiceEditPage({Key? key}) : super(key: key);

  @override
  _ServiceEditPageState createState() => _ServiceEditPageState();
}

class _ServiceEditPageState extends State<ServiceEditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _initialName = '';
  String _initialTime = '';
  String _initialLocation = '';
  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    final userId = 7; // Replace with Provider if needed
    _fetchServiceInfo(userId);
  }

  void _fetchServiceInfo(int userId) async {
    const url = 'http://localhost/flutter_api/get_service_profile.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"user_id": userId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _initialName = data['name'] ?? '';
        _initialTime = data['waktu'] ?? '';
        _initialLocation = data['alamat'] ?? '';

        _nameController.text = _initialName;
        _timeController.text = _initialTime;
        _locationController.text = _initialLocation;
      });

      _nameController.addListener(_checkEditState);
      _timeController.addListener(_checkEditState);
      _locationController.addListener(_checkEditState);
    }
  }

  void _checkEditState() {
    setState(() {
      _isEdited = _nameController.text != _initialName ||
          _timeController.text != _initialTime ||
          _locationController.text != _initialLocation;
    });
  }

  void _submitUpdate() async {
    const url = 'http://localhost/flutter_api/update_service.php';
    final userId = 7; // Replace with Provider if needed

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": userId,
        "name": _nameController.text,
        "waktu": _timeController.text,
        "alamat": _locationController.text,
      }),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil diperbarui")),
        );
        setState(() {
          _isEdited = false;
          _initialName = _nameController.text;
          _initialTime = _timeController.text;
          _initialLocation = _locationController.text;
        });

        await Future.delayed(const Duration(milliseconds: 500));

        // Redirect to dashboard
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  const Servicedashboard(), // adjust if your dashboard has a different name
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memperbarui")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF7FD),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  BackButton(),
                  const SizedBox(width: 8),
                  const Text(
                    'Kustomisasi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Image Picker Placeholder
            GestureDetector(
              onTap: () {
                // Add image picker logic later
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://via.placeholder.com/150',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Form Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Nama'),
                  _buildTextField(_nameController, 'Nama Penyedia Jasa'),
                  const SizedBox(height: 16),
                  _buildLabel('Waktu Operasional'),
                  _buildTextField(_timeController, 'Waktu Operasional'),
                  const SizedBox(height: 16),
                  _buildLabel('Lokasi'),
                  _buildTextField(_locationController, 'Lokasi Penyedia Jasa'),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isEdited ? _submitUpdate : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isEdited ? const Color(0xFF47C7F4) : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Perbarui',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
