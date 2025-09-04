import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/subscription_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

// 1. تحديث كلاس Recommendation بالكامل
class Recommendation {
  final String pair;
  final String direction;
  final String timeframe;
  final String entryTime;
  final String? forecast;
  final String? payout;
  final String? result;
  final bool isVip;

  const Recommendation({
    required this.pair,
    required this.direction,
    required this.timeframe,
    required this.entryTime,
    this.forecast,
    this.payout,
    this.result,
    required this.isVip,
  });

  factory Recommendation.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Recommendation(
      pair: data['pair'] ?? '',
      direction: data['direction']?.toLowerCase() ?? 'n/a',
      timeframe: data['timeframe'] ?? 'N/A',
      entryTime: data['entryTime'] ?? '--:--:--',
      forecast: data['forecast'],
      payout: data['payout'],
      result: data['result'],
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
  Future<bool> _fetchUserVipStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return false;
    return userDoc.data()?['isVip'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // ... build method يبقى كما هو
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('التوصيات - SIGNAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0A4F46), Colors.black], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: FutureBuilder<bool>(
          future: _fetchUserVipStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final bool isUserVip = snapshot.data ?? false;
            return _buildRecommendationsList(isUserVip);
          },
        ),
      ),
    );
  }

  Widget _buildRecommendationsList(bool isUserVip) {
    // ... StreamBuilder يبقى كما هو
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('recommendations').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('لا توجد توصيات حاليًا', style: TextStyle(color: Colors.white)));

        final recommendations = snapshot.data!.docs.map((doc) => Recommendation.fromFirestore(doc)).toList();
        final filteredRecommendations = isUserVip ? recommendations : recommendations.where((rec) => !rec.isVip).toList();

        if (!isUserVip && filteredRecommendations.isEmpty) return _buildVipLockScreen();

        return ListView.builder(
          padding: const EdgeInsets.only(top: 120, bottom: 20),
          itemCount: filteredRecommendations.length,
          itemBuilder: (context, index) {
            final rec = filteredRecommendations[index];
            return Column(children: [
              _buildRecommendationCard(rec), 
              _buildResultBanner(rec.result)
            ]);
          },
        );
      },
    );
  }

  // 2. إعادة تصميم بطاقة التوصية بالكامل
  Widget _buildRecommendationCard(Recommendation rec) {
    final bool isCall = rec.direction == 'call';
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(rec.pair.replaceAll('-', ' - '), style: TextStyle(color: Colors.yellow[600], fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailColumn('الاتجاه', isCall ? Icons.arrow_upward : Icons.arrow_downward, isCall ? Colors.greenAccent : Colors.redAccent),
                _buildDetailColumn('وقت الدخول', rec.entryTime, Colors.cyanAccent),
                _buildDetailColumn('المده', rec.timeframe, Colors.cyanAccent),
              ],
            ),
            // --- إضافة البيانات الجديدة هنا ---
            if (rec.forecast != null || rec.payout != null) ...[
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (rec.forecast != null) _buildExtraDetailRow(Icons.analytics_outlined, "Forecast: ${rec.forecast}%"),
                  if (rec.payout != null) _buildExtraDetailRow(Icons.monetization_on_outlined, "Payout: ${rec.payout}%"),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  // ... باقي الويدجتس تبقى كما هي تقريبًا
  Widget _buildResultBanner(String? result) {
    // ... الكود كما هو
    if (result == null) {
      return Container(
          width: 200,
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(30.0)),
          child: Shimmer.fromColors(
              baseColor: Colors.grey[600]!,
              highlightColor: Colors.grey[500]!,
              child: const Center(child: Text('في انتظار النتيجة...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))));
    } else if (result == 'win') {
      return Container(
          width: 150,
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(30.0), boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 10)]),
          child: const Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('ربح', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ])));
    } else {
      return Container(
          width: 150,
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(30.0), boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10)]),
          child: const Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.cancel, color: Colors.white),
            SizedBox(width: 8),
            Text('خسارة', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ])));
    }
  }

  Widget _buildDetailColumn(String title, dynamic value, Color valueColor) {
    // ... الكود كما هو
    return Column(children: [
      Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 8),
      if (value is IconData) Icon(value, color: valueColor, size: 30) else Text(value.toString(), style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildExtraDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    // ... الكود كما هو
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5)),
          child: child,
        ),
      ),
    );
  }

  Widget _buildVipLockScreen() {
    // ... الكود كما هو
    return Center(
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SubscriptionPage())),
        child: const Text("الترقية الآن"),
      ),
    );
  }
}