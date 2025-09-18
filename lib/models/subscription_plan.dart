import 'package:flutter/material.dart';

class SubscriptionPlan {
  final String id;
  final String title;
  final String monthlyPrice;
  final String yearlyPrice;
  final String? freePrice;
  final List<String> features;
  final Color borderColor;
  final Color backgroundColor;
  final bool isRecommended;
  final bool isFree;
  final String? badge;
  final IconData icon;
  final double savings; // نسبة التوفير للخطة السنوية

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.monthlyPrice,
    required this.yearlyPrice,
    this.freePrice,
    required this.features,
    required this.borderColor,
    required this.backgroundColor,
    this.isRecommended = false,
    this.isFree = false,
    this.badge,
    required this.icon,
    this.savings = 0,
  });

  static List<SubscriptionPlan> getPlans() {
    return [
      const SubscriptionPlan(
        id: 'free',
        title: 'مجانية',
        monthlyPrice: '0\$',
        yearlyPrice: '0\$',
        freePrice: '0\$',
        features: [
          'الوصول للمحتوى التعليمي الأساسي',
          'الوصول لقسم الاختبار لتقييم مستواك',
          'الحصول علي توقعات استقرار السوق',
          'اسعار اهم العملات',
        ],
        borderColor: Color(0xFF6B7280),
        backgroundColor: Color(0xFF374151),
        isFree: true,
        icon: Icons.star_border,
      ),
      const SubscriptionPlan(
        id: 'platinum',
        title: 'بلاتينيوم',
        monthlyPrice: '35.00\$',
        yearlyPrice: '200.00\$',
        features: [
          '\u202B150 صفقة علي مدار اليوم\u202C',
          '\u202Bنسبة ربح التوصيات %85\u202C',
          'فتح قسم الاستراتيجيات المدفوعه',
          'فتح قسم التوصيات',
          'تحليلات متقدمة',
          'دعم فني متوفر 24 ساعه',
        ],
        borderColor: Color(0xFF3B82F6),
        backgroundColor: Color(0xFF1E3A8A),
        icon: Icons.diamond,
        savings: 50,
      ),
      const SubscriptionPlan(
        id: 'gold',
        title: 'ذهبية',
        monthlyPrice: '50.00\$',
        yearlyPrice: '300.00\$',
        features: [
          '\u202B300 صفقة علي مدار اليوم\u202C',
          '\u202Bنسبة ربح التوصيات %98\u202C',
          'فتح قسم الاستراتيجيات المدفوعه',
          'فتح قسم التوصيات',
          'تحليلات متقدمة',
          'مؤشرات تداول حصرية',
          'استشارات شخصية 24/7',
          'أولوية في الإشعارات',
        ],
        borderColor: Color(0xFFEAB308),
        backgroundColor: Color(0xFFB45309),
        isRecommended: true,
        badge: 'الأكثر اشتراكا',
        icon: Icons.workspace_premium,
        savings: 50,
      ),
    ];
  }
}

/// ويدجت لعرض تفاصيل الخطة
class PlanDetails extends StatelessWidget {
  final SubscriptionPlan plan;

  const PlanDetails({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: plan.features.map((f) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check, color: Colors.green, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                f,
                textDirection: TextDirection.rtl, // ✅ يجبر RTL
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
