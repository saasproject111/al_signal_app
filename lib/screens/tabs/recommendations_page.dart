import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/subscription_page.dart';
import 'package:shimmer/shimmer.dart';

// كلاس لتمثيل بيانات التوصية
class Recommendation {
  final String pair;
  final String direction;
  final String timeframe;
  final String entryTime;
  final String? forecast;
  final String? payout;
  final bool isVip;

  const Recommendation({
    required this.pair,
    required this.direction,
    required this.timeframe,
    required this.entryTime,
    this.forecast,
    this.payout,
    required this.isVip,
  });

  // دالة لتحويل البيانات من Firestore إلى كائن Recommendation
  factory Recommendation.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Recommendation(
      pair: data['pair'] ?? '',
      direction: data['direction']?.toLowerCase() ?? 'n/a',
      timeframe: data['timeframe'] ?? 'N/A',
      entryTime: data['entryTime'] ?? '--:--:--',
      forecast: data['forecast'],
      payout: data['payout'],
      isVip: data['isVip'] ?? false,
    );
  }
}

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});
  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  // دالة لجلب حالة اشتراك المستخدم
  Future<bool> _fetchUserVipStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return false;
    return userDoc.data()?['isVip'] ?? false;
  }

  // دالة التحديث عند السحب
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('التوصيات - SIGNAL',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A4F46), // لون ثابت بدل الشفاف
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF0A4F46), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: FutureBuilder<bool>(
          future: _fetchUserVipStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final bool isUserVip = snapshot.data ?? false;
            return _buildRecommendationsList(isUserVip);
          },
        ),
      ),
    );
  }

  // ويدجت بناء القائمة
  Widget _buildRecommendationsList(bool isUserVip) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      backgroundColor: Colors.blueGrey[900],
      color: Colors.tealAccent,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recommendations')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return _buildShimmerLoadingList();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Stack(children: [
              const Center(
                  child: Text('لا توجد توصيات حاليًا',
                      style: TextStyle(color: Colors.white))),
              if (!isUserVip) _buildVipLockOverlay(),
            ]);
          }

          final recommendations = snapshot.data!.docs
              .map((doc) => Recommendation.fromFirestore(doc))
              .toList();

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(
                    top: 120, bottom: 20, left: 16, right: 16),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final rec = recommendations[index];
                  return _buildRecommendationCard(rec);
                },
              ),
              if (!isUserVip) _buildVipLockOverlay(),
            ],
          );
        },
      ),
    );
  }

  // --- ويدجتس مساعدة ---

  Widget _buildShimmerLoadingList() {
    return ListView(
      padding:
          const EdgeInsets.only(top: 120, bottom: 20, left: 16, right: 16),
      children: List.generate(3, (index) => _buildShimmerCard()),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[800]!,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }

  Widget _buildVipLockOverlay() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      color: Colors.yellow[700], size: 80),
                  const SizedBox(height: 20),
                  const Text('محتوى حصري للمشتركين',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                      'قم بالترقية لرؤية جميع التوصيات الفورية بوضوح.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15)),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                const SubscriptionPage())),
                    child: const Text('الترقية الآن',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(Recommendation rec) {
    final bool isCall = rec.direction == 'call';
    Color borderColor = Colors.white.withOpacity(0.2);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(color: borderColor, width: 1.5)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(rec.pair.replaceAll('-', ' - '),
                      style: TextStyle(
                          color: Colors.yellow[600],
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailColumn(
                          'الاتجاه',
                          isCall
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          isCall
                              ? Colors.greenAccent
                              : Colors.redAccent),
                      _buildDetailColumn(
                          'وقت الدخول', rec.entryTime, Colors.cyanAccent),
                      _buildDetailColumn(
                          'المده', rec.timeframe, Colors.cyanAccent),
                    ],
                  ),
                  if (rec.forecast != null || rec.payout != null) ...[
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (rec.forecast != null)
                          _buildExtraDetailRow(
                              Icons.analytics_outlined,
                              "Forecast: ${rec.forecast}%"),
                        if (rec.payout != null)
                          _buildExtraDetailRow(
                              Icons.monetization_on_outlined,
                              "Payout: ${rec.payout}%"),
                      ],
                    ),
                  ],
                  // ❌ تم حذف النتيجة (ربح/خسارة/انتظار)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String title, dynamic value, Color valueColor) {
    return Column(children: [
      Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 8),
      if (value is IconData)
        Icon(value, color: valueColor, size: 30)
      else
        Text(value.toString(),
            style: TextStyle(
                color: valueColor, fontSize: 20, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildExtraDetailRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, color: Colors.white60, size: 16),
      const SizedBox(width: 6),
      Text(text,
          style: const TextStyle(color: Colors.white70, fontSize: 14)),
    ]);
  }
}