import 'package:flutter/material.dart';
import 'package:my_app/widgets/payment_methods_sheet.dart';

enum SubscriptionPlan { monthly, yearly }

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> with SingleTickerProviderStateMixin {
  bool _isYearly = false;
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _animations = List.generate(3, (index) => Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Interval(0.2 * index, 0.6 + 0.2 * index, curve: Curves.easeOutCubic))));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPaymentMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return const PaymentMethodsSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0A4F46), Colors.black], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: SafeArea(
            child: Column(
              children: [
                const Text('اختر خطتك', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('احصل على وصول غير محدود لكل الميزات', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 30),
                _buildBillingToggle(),
                const SizedBox(height: 30),
                _buildAnimatedPlanCard(
                  animation: _animations[0],
                  title: 'مجانية',
                  price: '0\$',
                  period: 'للأبد',
                  features: ['الوصول للمحتوى التعليمي الأساسي', 'توصيات مجانية محدودة'],
                  borderColor: Colors.grey,
                  isFree: true,
                ),
                const SizedBox(height: 20),
                _buildAnimatedPlanCard(
                  animation: _animations[1],
                  title: 'بلاتينيوم',
                  monthlyPrice: '9.99\$',
                  yearlyPrice: '59.99\$',
                  features: ['كل مميزات الخطة المجانية', 'جميع التوصيات الفورية', 'استراتيجيات التداول الحصرية', 'إشعارات VIP'],
                  borderColor: Colors.lightBlue[300]!,
                ),
                const SizedBox(height: 20),
                _buildAnimatedPlanCard(
                  animation: _animations[2],
                  title: 'ذهبية',
                  monthlyPrice: '19.99\$',
                  yearlyPrice: '119.99\$',
                  features: ['كل مميزات البلاتينيوم', 'جلسات تحليل أسبوعية', 'دعم فني مباشر', 'مؤشرات خاصة'],
                  borderColor: Colors.yellow[700]!,
                  isRecommended: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillingToggle() {
    return GestureDetector(
      onTap: () { setState(() { _isYearly = !_isYearly; }); },
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(25)),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: _isYearly ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(25)),
              ),
            ),
            Row(
              children: [
                Expanded(child: Center(child: Text('شهري', style: TextStyle(color: _isYearly ? Colors.white70 : Colors.white, fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text('سنوي', style: TextStyle(color: _isYearly ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPlanCard({
    required Animation<double> animation,
    required String title,
    String? price,
    String? period,
    String? monthlyPrice,
    String? yearlyPrice,
    required List<String> features,
    required Color borderColor,
    bool isRecommended = false,
    bool isFree = false,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [BoxShadow(color: borderColor.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(20)),
                  child: const Text('الأكثر شيوعًا', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              if (isRecommended) const SizedBox(height: 10),
              Text(title, style: TextStyle(color: borderColor, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (!isFree) Text(_isYearly ? yearlyPrice! : monthlyPrice!, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              if (isFree) Text(price!, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              Text(_isYearly && !isFree ? '/ سنة' : (isFree ? period! : '/ شهر'), style: const TextStyle(color: Colors.white70)),
              const Divider(color: Colors.white24, height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: borderColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(feature, style: const TextStyle(color: Colors.white, fontSize: 16))),
                    ],
                  ),
                )).toList(),
              ),
              if (!isFree)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  // --- تم التعديل هنا ---
                  child: Builder( // استخدام Builder للحصول على سياق صحيح
                    builder: (buttonContext) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: borderColor,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showPaymentMethods(buttonContext),
                        child: const Text('اختر الخطة', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      );
                    }
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

