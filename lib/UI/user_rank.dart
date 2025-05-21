import 'package:flutter/material.dart';
import 'package:flutter/material.dart' show Symbols;
import 'package:material_symbols_icons/material_symbols_icons.dart';

class UserRankPage extends StatelessWidget {
  const UserRankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Member'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Group_77.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Icon(Symbols.award_star, color: Colors.white, size: 40),
                      SizedBox(width: 10),
                      Text(
                        'BUDDY',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tingkatkan terus dengan melakukan transaksi\nuntuk mendapatkan hadiah-hadiah menarik lebih banyak.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 3962 / 10000,
                          backgroundColor: Colors.white30,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.yellow),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.stars, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '3.962 XP / 10.000 XP',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            // Rank Level Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _LevelIcon(title: 'Pal', isActive: false),
                  _LevelIcon(title: 'Buddy', isActive: true),
                  _LevelIcon(title: 'Champ', isActive: false),
                  _LevelIcon(title: 'Royal', isActive: false),
                ],
              ),
            ),

            // Benefit Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Icon(Symbols.local_activity,
                      color: Color(0xFF6A6D7C), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Keuntungan member Buddy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A6D7C),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Keuntungan transaksi khusus member ini',
                style: TextStyle(color: Color(0xFF6A6D7C)),
              ),
            ),

            // Benefit Cards
            const SizedBox(height: 12),
            const _BenefitCard(
              title: 'Promo Spesial',
              subtitle: 'Dapatkan berbagai promo khusus untuk member.',
              icon: Icons.local_offer,
            ),
            const _BenefitCard(
              title: 'Poin Loyalty',
              subtitle: 'Dapatkan Paw-Point setiap melakukan transaksi.',
              icon: Icons.calculate_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelIcon extends StatelessWidget {
  final String title;
  final bool isActive;

  const _LevelIcon({required this.title, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: isActive ? 24 : 20,
          backgroundColor:
              isActive ? const Color(0xFF6B75FF) : Colors.grey.shade300,
          child: Icon(
            Symbols.award_star,
            color: Colors.white,
            size: isActive ? 24 : 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF6B75FF) : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _BenefitCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6B75FF), // Buddy rank card color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}
