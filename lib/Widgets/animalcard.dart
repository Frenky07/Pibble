import 'package:flutter/material.dart';

class AnimalCard extends StatelessWidget {
  final Color backgroundColor;
  final IconData iconData;
  final String name;
  final bool isSelected;

  const AnimalCard({
    Key? key,
    required this.backgroundColor,
    required this.iconData,
    required this.name,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                iconData,
                size: 32,
                color: Colors.white,
              ),
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
}
