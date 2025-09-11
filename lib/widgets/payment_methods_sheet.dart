import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/subscription_plan.dart'; // استيراد SubscriptionPlan من النماذج فقط
import '../utils/app_colors.dart';
import '../screens/premium_usdt_checkout_page.dart';
// دالة تحمي الـ opacity
Color safeOpacity(Color color, double opacity) {
  if (opacity < 0.0) opacity = 0.0;
  if (opacity > 1.0) opacity = 1.0;
  return color.withOpacity(opacity);
}

// ===== تعريف PaymentMethod خارج أي كلاس =====
class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool isEnabled;
  final Color color;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isEnabled,
    required this.color,
  });
}

class PaymentMethodsSheet extends StatefulWidget {
  final SubscriptionPlan selectedPlan;
  final bool isYearly;

  const PaymentMethodsSheet({
    super.key,
    required this.selectedPlan,
    required this.isYearly,
  });

  @override
  State<PaymentMethodsSheet> createState() => _PaymentMethodsSheetState();
}

class _PaymentMethodsSheetState extends State<PaymentMethodsSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'visa_mastercard',
      name: 'Visa / Mastercard',
      description: 'غير متاح حالياً - قريبًا',
      icon: Icons.credit_card,
      isEnabled: false,
      color: const Color(0xFF1565C0),
    ),
    PaymentMethod(
      id: 'usdt',
      name: 'USDT (Tether)',
      description: '% دفع عن طريق العملات الرقميه امن 100',
      icon: Icons.currency_bitcoin,
      isEnabled: true,
      color: const Color(0xFF26A17B),
    ),
    PaymentMethod(
      id: 'paypal',
      name: 'PayPal',
      description: 'paybal دفع عن طريق',
      icon: Icons.account_balance_wallet,
      isEnabled: false,
      color: const Color(0xFF0070BA),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: safeOpacity(Colors.black, 0.5),
        child: SlideTransition(
          position: _slideAnimation,
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1F2937),
                      Color(0xFF111827),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    _buildHandle(),
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _buildPlanSummary(),
                            const SizedBox(height: 24),
                            _buildPaymentMethods(),
                            const SizedBox(height: 24),
                            _buildSecurityInfo(),
                            const SizedBox(height: 24),
                            _buildActionButtons(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: safeOpacity(Colors.white, 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: safeOpacity(widget.selectedPlan.borderColor, 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.payment,
              color: widget.selectedPlan.borderColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر طريقة الدفع',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'لإتمام اشتراك ${widget.selectedPlan.title}',
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSummary() {
    final price = widget.isYearly
        ? widget.selectedPlan.yearlyPrice
        : widget.selectedPlan.monthlyPrice;
    final period = widget.isYearly ? 'سنوي' : 'شهري';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            safeOpacity(widget.selectedPlan.borderColor, 0.1),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: safeOpacity(widget.selectedPlan.borderColor, 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.selectedPlan.icon,
            color: widget.selectedPlan.borderColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خطة ${widget.selectedPlan.title}',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'اشتراك $period',
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.cairo(
                  color: widget.selectedPlan.borderColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.isYearly && widget.selectedPlan.savings > 0)
                Text(
                  'وفر ${widget.selectedPlan.savings.toInt()}%',
                  style: GoogleFonts.cairo(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طرق الدفع المتاحة',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: method.isEnabled
              ? () => setState(() => _selectedPaymentMethod = method.id)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? safeOpacity(method.color, 0.1)
                  : safeOpacity(Colors.white, 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? method.color
                    : safeOpacity(Colors.white, 0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: safeOpacity(
                        method.color, method.isEnabled ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    method.icon,
                    color: method.isEnabled
                        ? method.color
                        : safeOpacity(Colors.white, 0.3),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.name,
                        style: GoogleFonts.cairo(
                          color: method.isEnabled
                              ? Colors.white
                              : safeOpacity(Colors.white, 0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        method.description,
                        style: GoogleFonts.cairo(
                          color: method.isEnabled
                              ? (method.id == 'visa_mastercard'
                                  ? Colors.orange
                                  : Colors.white70)
                              : safeOpacity(Colors.white, 0.3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (method.isEnabled)
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected
                        ? method.color
                        : safeOpacity(Colors.white, 0.3),
                  ),
                if (!method.isEnabled)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: safeOpacity(Colors.orange, 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'قريباً',
                      style: GoogleFonts.cairo(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: safeOpacity(Colors.green, 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: safeOpacity(Colors.green, 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.security,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'جميع المعاملات مشفرة وآمنة 100%. يمكنك إلغاء الاشتراك في أي وقت.',
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedPaymentMethod != null && !_isProcessing
                ? _handlePayment
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.selectedPlan.borderColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'إتمام الدفع',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إلغاء',
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _handlePayment() async {
    if (_selectedPaymentMethod == 'usdt') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => USDTCheckoutPage(
            selectedPlan: widget.selectedPlan,
            isYearly: widget.isYearly,
          ),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: safeOpacity(Colors.green, 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تم الاشتراك بنجاح!',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'مرحباً بك في خطة ${widget.selectedPlan.title}',
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'ممتاز!',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
