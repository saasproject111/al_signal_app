import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/subscription_page.dart'; // 1. استيراد صفحة الاشتراكات
import 'package:url_launcher/url_launcher.dart';

// كلاس Lecture و LearningSection يبقيان كما هما
class Lecture {
  final String title;
  final String youtubeUrl;
  Lecture({required this.title, required this.youtubeUrl});
  factory Lecture.fromMap(Map<String, dynamic> data) {
    return Lecture(title: data['title'] ?? 'N/A', youtubeUrl: data['youtubeUrl'] ?? '');
  }
}

class LearningSection {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Lecture> lectures;
  final bool isVip;
  LearningSection({required this.title, required this.subtitle, required this.icon, required this.lectures, this.isVip = false});
  factory LearningSection.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    IconData _getIconFromString(String iconName) {
      switch (iconName) {
        case 'bar_chart': return Icons.bar_chart;
        case 'psychology': return Icons.psychology;
        case 'candlestick_chart': return Icons.candlestick_chart;
        case 'timeline': return Icons.timeline;
        case 'star': return Icons.star;
        default: return Icons.school;
      }
    }
    var lecturesData = data['lectures'] as List<dynamic>? ?? [];
    List<Lecture> lecturesList = lecturesData.map((lecture) => Lecture.fromMap(lecture)).toList();
    return LearningSection(
      title: data['title'] ?? 'N/A',
      subtitle: data['subtitle'] ?? '',
      icon: _getIconFromString(data['icon_name'] ?? ''),
      lectures: lecturesList,
      isVip: data['isVip'] ?? false,
    );
  }
}

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});
  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  Future<bool> _fetchUserVipStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return false;
    return userDoc.data()?['isVip'] ?? false;
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('التــــــعلم - LEARNING', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A4F46), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<bool>(
          future: _fetchUserVipStatus(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final bool isUserVip = userSnapshot.data ?? false;
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('learning_sections').orderBy('timestamp').snapshots(),
              builder: (context, sectionsSnapshot) {
                if (sectionsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!sectionsSnapshot.hasData) {
                  return const Center(child: Text('لا يوجد محتوى', style: TextStyle(color: Colors.white)));
                }
                final sections = sectionsSnapshot.data!.docs.map((doc) => LearningSection.fromFirestore(doc)).toList();
                return ListView(
                  padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white24, thickness: 1),
                    const SizedBox(height: 10),
                    ...sections.map((section) => _buildSectionCard(section, isUserVip)).toList(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text('خطوتك الأولى في عالم التداول “بيناري - فوركس”', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('هذا الكورس كفيل يحولك من مبتدأ الى محترف في اقل من شهر', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 20),
        Image.asset('assets/book_logo.png', height: 120, errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.school, size: 120, color: Colors.tealAccent);
        }),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSectionCard(LearningSection section, bool isUserVip) {
    final bool isLocked = section.isVip && !isUserVip;
    final cardColor = section.isVip ? Colors.teal.withOpacity(0.3) : Colors.black.withOpacity(0.25);
    final iconColor = section.isVip ? Colors.yellow[700] : Colors.white;
    if (isLocked) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0), side: BorderSide(color: Colors.grey[800]!)),
        child: ListTile(
          leading: Icon(Icons.lock, color: Colors.grey[700]),
          title: Text(section.title, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.lineThrough)),
          subtitle: Text('محتوى حصري للمشتركين', style: TextStyle(color: Colors.grey[700])),
          trailing: Icon(Icons.star, color: Colors.yellow[800]),
          // --- 2. تم التعديل هنا لربط زر الترقية ---
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SubscriptionPage()),
            );
          },
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0), side: section.isVip ? BorderSide(color: Colors.yellow[700]!, width: 1.5) : BorderSide.none),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(section.icon, color: iconColor),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: Text(section.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(section.subtitle, style: const TextStyle(color: Colors.white70)),
        children: section.lectures.map((lecture) {
          return ListTile(
            leading: const Icon(Icons.play_circle_outline, color: Colors.tealAccent),
            title: Text(lecture.title, style: const TextStyle(color: Colors.white)),
            onTap: () => _launchURL(lecture.youtubeUrl),
          );
        }).toList(),
      ),
    );
  }
}