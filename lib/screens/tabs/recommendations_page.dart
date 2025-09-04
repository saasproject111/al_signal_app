import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/subscription_page.dart'; // استيراد صفحة الاشتراكات

// كلاس Recommendation يبقى كما هو
class Recommendation {
  final String pair;
  final String direction;
  final String entryPoint;
  final String status;
  final Color statusColor;
  final bool isVip;

  const Recommendation({
    required this.pair,
    required this.direction,
    required this.entryPoint,
    required this.status,
    required this.statusColor,
    required this.isVip,
  });

  factory Recommendation.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    Color determineStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'نشطة': return Colors.greenAccent;
        case 'مكتملة': return Colors.blueAccent;
        case 'ملغاة': return Colors.redAccent;
        default: return Colors.grey;
      }
    }
    return Recommendation(
      pair: data['pair'] ?? '',
      direction: data['direction'] ?? 'N/A',
      entryPoint: data['entryPoint'] ?? '0.0',
      status: data['status'] ?? 'غير معروف',
      isVip: data['isVip'] ?? false,
      statusColor: determineStatusColor(data['status'] ?? ''),
    );
  }
}

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});
  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  Future<bool> _fetchUserVipStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return false;
    return userDoc.data()?['isVip'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('التوصيات', style: TextStyle(color: Colors.white)),
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
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('حدث خطأ ما', style: TextStyle(color: Colors.white)));
            }
            final bool isUserVip = snapshot.data ?? false;
            
            // --- تم التعديل هنا لتمرير حالة VIP ---
            return _buildRecommendationsList(isUserVip);
          },
        ),
      ),
    );
  }

  Widget _buildRecommendationsList(bool isUserVip) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('recommendations').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('حدث خطأ في جلب البيانات', style: TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('لا توجد توصيات حاليًا', style: TextStyle(color: Colors.white)));
        }

        final allRecommendations = snapshot.data!.docs.map((doc) => Recommendation.fromFirestore(doc)).toList();

        // --- تم التعديل هنا لفلترة التوصيات ---
        final filteredRecommendations = isUserVip
            ? allRecommendations // المستخدم الـ VIP يرى كل شيء
            : allRecommendations.where((rec) => !rec.isVip).toList(); // المستخدم العادي يرى التوصيات المجانية فقط

        // إذا كان المستخدم عاديًا ولا توجد توصيات مجانية، أظهر شاشة القفل
        if (!isUserVip && filteredRecommendations.isEmpty) {
          return _buildVipLockScreen();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 100),
          itemCount: filteredRecommendations.length,
          itemBuilder: (context, index) {
            final rec = filteredRecommendations[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.black.withOpacity(0.25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: rec.direction == 'شراء' ? Colors.green : Colors.red,
                  child: Icon(rec.direction == 'شراء' ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white),
                ),
                title: Text(rec.pair, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('نقطة الدخول: ${rec.entryPoint}', style: const TextStyle(color: Colors.white70)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: rec.statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: rec.statusColor),
                  ),
                  child: Text(rec.status, style: TextStyle(color: rec.statusColor, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVipLockScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, color: Colors.yellow[700], size: 80),
            const SizedBox(height: 20),
            const Text('محتوى حصري للمشتركين', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('قم بالترقية إلى عضوية VIP للوصول إلى جميع التوصيات الفورية.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700], padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              // --- تم التعديل هنا لربط زر الترقية ---
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                );
              },
              child: const Text('الترقية الآن', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}