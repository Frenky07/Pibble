import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pibble/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

// Import your UserProvider here
// import 'path/to/your/user_provider.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({Key? key}) : super(key: key);

  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  bool isLoading = true;
  String error = '';
  
  int memberPoints = 0;
  List<MemberLevel> levels = [];
  MemberLevel? currentLevel;
  MemberLevel? nextLevel;
  
  @override
  void initState() {
    super.initState();
    fetchMemberData();
  }

  Future<void> fetchMemberData() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      // Get user ID from provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;

      // Check if user ID is valid
      if (userId == 0) {
        setState(() {
          error = 'User not logged in';
          isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://localhost/flutter_api/get_member.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['error'] != null) {
          setState(() {
            error = data['error'];
            isLoading = false;
          });
          return;
        }

        setState(() {
          memberPoints = data['member_points'];
          levels = (data['levels'] as List)
              .map((level) => MemberLevel.fromJson(level))
              .toList();
          
          // Sort levels by points requirement
          levels.sort((a, b) => a.pointsReq.compareTo(b.pointsReq));
          
          // Find current and next level
          currentLevel = getCurrentLevel();
          nextLevel = getNextLevel();
          
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load member data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  MemberLevel? getCurrentLevel() {
    MemberLevel? current;
    for (var level in levels) {
      if (memberPoints >= level.pointsReq) {
        current = level;
      }
    }
    return current;
  }

  MemberLevel? getNextLevel() {
    for (var level in levels) {
      if (memberPoints < level.pointsReq) {
        return level;
      }
    }
    return null; // User is at max level
  }

  double getProgress() {
    if (nextLevel == null) return 1.0; // Max level reached
    
    int currentLevelPoints = currentLevel?.pointsReq ?? 0;
    int nextLevelPoints = nextLevel!.pointsReq;
    int progressPoints = memberPoints - currentLevelPoints;
    int totalNeeded = nextLevelPoints - currentLevelPoints;
    
    return progressPoints / totalNeeded;
  }

  String getProgressText() {
    if (nextLevel == null) {
      return 'Max Level Reached!';
    }
    return '$memberPoints XP / ${nextLevel!.pointsReq} XP';
  }

  Color getLevelColor(String hexColor) {
    // Remove # if present and ensure it's 6 characters
    String cleanHex = hexColor.replaceAll('#', '');
    if (cleanHex.length == 6) {
      return Color(int.parse('FF$cleanHex', radix: 16));
    }
    return Colors.blue; // Default fallback
  }

  String getLevelName(int levelId) {
    switch (levelId) {
      case 1:
        return 'PAL';
      case 2:
        return 'BUDDY';
      case 3:
        return 'CHAMP';
      case 4:
        return 'ROYAL';
      default:
        return 'MEMBER';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchMemberData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: 8),
                  Text('Member', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: fetchMemberData,
                  ),
                ],
              ),
            ),

            // Gradient Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: currentLevel != null 
                      ? [
                          getLevelColor(currentLevel!.color),
                          getLevelColor(currentLevel!.color).withOpacity(0.7),
                        ]
                      : [Color(0xFF8E7BF7), Color(0xFF5CC6F0)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 32),
                      SizedBox(width: 8),
                      Text(
                        getLevelName(currentLevel?.id ?? 1),
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    nextLevel != null 
                        ? "Tingkatkan terus dengan melakukan transaksi\nuntuk mencapai level ${getLevelName(nextLevel!.id)}."
                        : "Selamat! Anda telah mencapai level tertinggi.",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: getProgress(),
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      getProgressText(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Tier Row
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: currentLevel != null 
                    ? getLevelColor(currentLevel!.color).withOpacity(0.1)
                    : Color(0xFFE6F0FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: levels.map((level) => tierItem(
                  getLevelName(level.id),
                  memberPoints >= level.pointsReq ? Icons.star : Icons.star_border,
                  getLevelColor(level.color),
                  isCurrent: currentLevel?.id == level.id,
                )).toList(),
              ),
            ),

            // Benefits Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Icon(Icons.star, size: 18, 
                       color: currentLevel != null 
                           ? getLevelColor(currentLevel!.color)
                           : Colors.grey),
                  SizedBox(width: 6),
                  Text("Keuntungan member ${getLevelName(currentLevel?.id ?? 1)}", 
                       style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text("Keuntungan transaksi khusus member ini"),
            ),

            SizedBox(height: 16),

            // Promo Card
            benefitCard(
              title: "Promo Spesial",
              subtitle: "Dapatkan berbagai promo khusus untuk member.",
              icon: Icons.local_offer,
              color: currentLevel != null 
                  ? getLevelColor(currentLevel!.color).withOpacity(0.15)
                  : Color(0xFFD1DFFE),
            ),

            SizedBox(height: 12),

            // Loyalty Card
            benefitCard(
              title: "Poin Loyalty",
              subtitle: "Dapatkan Paw-Point setiap melakukan transaksi.",
              icon: Icons.calculate,
              color: currentLevel != null 
                  ? getLevelColor(currentLevel!.color).withOpacity(0.15)
                  : Color(0xFFD1DFFE),
            ),

            SizedBox(height: 12),

            // Points Info Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: currentLevel != null 
                    ? getLevelColor(currentLevel!.color).withOpacity(0.15)
                    : Color(0xFFD1DFFE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Points", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("$memberPoints XP earned"),
                      ],
                    ),
                  ),
                  Icon(Icons.workspace_premium, size: 32, 
                       color: currentLevel != null 
                           ? getLevelColor(currentLevel!.color)
                           : Colors.amber),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tierItem(String label, IconData icon, Color color, {bool isCurrent = false}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCurrent ? color.withOpacity(0.2) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(
          fontSize: 12,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        )),
      ],
    );
  }

  Widget benefitCard({
    required String title, 
    required String subtitle, 
    required IconData icon,
    Color? color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Color(0xFFD1DFFE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
          Icon(icon, size: 32),
        ],
      ),
    );
  }
}

class MemberLevel {
  final int id;
  final int pointsReq;
  final String color;

  MemberLevel({
    required this.id,
    required this.pointsReq,
    required this.color,
  });

  factory MemberLevel.fromJson(Map<String, dynamic> json) {
    return MemberLevel(
      id: int.parse(json['id'].toString()),
      pointsReq: int.parse(json['pointsreq'].toString()),
      color: json['color'].toString(),
    );
  }
}