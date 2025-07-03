import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ScheduleCard extends StatelessWidget {
  final String day;
  final String petName;
  final String serviceName;
  final String label;
  final Color color;
  final VoidCallback? onTap; // Add a callback for click events

  ScheduleCard({
    required this.day,
    required this.petName,
    required this.serviceName,
    required this.label,
    required this.color,
    this.onTap, // Optional callback
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Handle the tap
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Distribute space evenly
          children: [
            Container(
              width: 100, // Set a fixed width
              height: 50, // Set a fixed height
              color: Colors.transparent, // Invisible container
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 24,
                      child: Icon(
                        Symbols.stethoscope,
                        color: color,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          petName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '$serviceName - $label',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
