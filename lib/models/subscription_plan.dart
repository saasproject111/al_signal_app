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
          'توصيات مجانية محدودة',
          'تحليلات أساسية',
        ],
        borderColor: Color(0xFF6B7280),
        backgroundColor: Color(0xFF374151),
        isFree: true,
        icon: Icons.star_border,
      ),
      const SubscriptionPlan(
        id: 'platinum',
        title: 'بلاتينيوم',
        monthlyPrice: '9.99\$',
        yearlyPrice: '59.99\$',
        features: [
          'كل مميزات الخطة المجانية',
          'جميع التوصيات الفورية',
          'استراتيجيات التداول الحصرية',
          'إشعارات VIP',
          'تحليلات متقدمة',
        ],
        borderColor: Color(0xFF3B82F6),
        backgroundColor: Color(0xFF1E3A8A),
        icon: Icons.diamond,
        savings: 50,
      ),
      const SubscriptionPlan(
        id: 'gold',
        title: 'ذهبية',
        monthlyPrice: '19.99\$',
        yearlyPrice: '119.99\$',
        features: [
          'كل مميزات البلاتينيوم',
          'جلسات تحليل أسبوعية',
          'دعم فني مباشر 24/7',
          'مؤشرات خاصة حصرية',
          'استشارات شخصية',
          'أولوية في الإشعارات',
        ],
        borderColor: Color(0xFFEAB308),
        backgroundColor: Color(0xFFB45309),
        isRecommended: true,
        badge: 'الأكثر شيوعًا',
        icon: Icons.workspace_premium,
        savings: 50,
      ),
    ];
  }
}
