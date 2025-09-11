import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_plan.dart';

class USDTCheckoutPage extends StatefulWidget {
  final SubscriptionPlan selectedPlan;
  final bool isYearly;

  const USDTCheckoutPage({
    Key? key,
    required this.selectedPlan,
    required this.isYearly,
  }) : super(key: key);

  @override
  State<USDTCheckoutPage> createState() => _USDTCheckoutPageState();
}

class _USDTCheckoutPageState extends State<USDTCheckoutPage>
    with TickerProviderStateMixin {
  String selectedNetwork = "TRC20";
  bool hasPaid = false;
  bool isLoading = true;

  Map<String, String> networkAddresses = {};

  final Map<String, String> contactLinks = {
    "platinum_monthly": "https://t.me/m/2nNgCWaxZjE0",
    "platinum_yearly": "https://t.me/m/Cv1K62WVYWM8",
    "gold_monthly": "https://t.me/m/6tbr8Ir4Yjg8",
    "gold_yearly": "https://t.me/m/YStvhuZIYjI0",
  };

  // Animation Controllers
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  // Animations
  late Animation<double> _backgroundAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchAddresses();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _waveController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _backgroundAnimation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_backgroundController);
    _waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_waveController);
    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _slideController.forward();
    });
  }

  Future<void> _fetchAddresses() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('usdt_addresses').get();

      final Map<String, String> addresses = {};
      for (var doc in snapshot.docs) {
        addresses[doc.id] = doc['address'] ?? '';
      }

      setState(() {
        networkAddresses = addresses;
        if (!networkAddresses.containsKey(selectedNetwork)) {
          selectedNetwork = networkAddresses.keys.isNotEmpty
              ? networkAddresses.keys.first
              : "TRC20";
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("تعذر فتح الرابط"),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade300),
              const SizedBox(width: 8),
              const Text("تم نسخ العنوان بنجاح"),
            ],
          ),
          backgroundColor: const Color(0xFF1A5F56).withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String price = widget.isYearly
        ? widget.selectedPlan.yearlyPrice
        : widget.selectedPlan.monthlyPrice;

    String contactKey =
        "${widget.selectedPlan.id}_${widget.isYearly ? 'yearly' : 'monthly'}";
    String contactLink = contactLinks[contactKey] ?? "https://t.me/default";
    String address = networkAddresses[selectedNetwork] ?? "";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAnimatedAppBar(),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildContent(price, address, contactLink),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAnimatedAppBar() {
    return AppBar(
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: const Text(
          "💎 ادفع بالـ USDT",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child:
              const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A4F46).withOpacity(0.8),
              const Color(0xFF0D1B2A).withOpacity(0.6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _backgroundAnimation,
        _waveAnimation,
        _glowAnimation,
        _particleController,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF0A4F46),
                  const Color(0xFF1A5F56),
                  (sin(_backgroundAnimation.value) + 1) / 2,
                )!,
                Color.lerp(
                  const Color(0xFF0D1B2A),
                  const Color(0xFF1A2332),
                  (cos(_backgroundAnimation.value + pi / 3) + 1) / 2,
                )!,
                Color.lerp(
                  Colors.black,
                  const Color(0xFF0A1A2A),
                  (sin(_backgroundAnimation.value + pi / 2) + 1) / 2,
                )!,
                Color.lerp(
                  const Color(0xFF0A4F46),
                  const Color(0xFF2A6F66),
                  (cos(_backgroundAnimation.value + pi) + 1) / 2,
                )!,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: CombinedEffectsPainter(
              _waveAnimation.value,
              _particleController.value,
              _glowAnimation.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  // #############################################
  // ########## الكود الذي تم تصحيحه هنا ##########
  // #############################################
  Widget _buildContent(String price, String address, String contactLink) {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          // 1. تم إضافة SingleChildScrollView لجعل المحتوى قابل للتمرير
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildNetworkSelector(),
                  const SizedBox(height: 30),
                  _buildQRCodeSection(address),
                  const SizedBox(height: 25),
                  _buildAddressSection(address),
                  const SizedBox(height: 20),
                  _buildInstructions(price),
                  const SizedBox(height: 30),
                  _buildPaymentCheckbox(),
                  // 2. تم استبدال Spacer بـ SizedBox
                  const SizedBox(height: 40),
                  _buildActionButton(contactLink),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkSelector() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A5F56).withOpacity(0.3),
              const Color(0xFF2A6F66).withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: networkAddresses.keys.map((network) {
              bool isSelected = selectedNetwork == network;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => selectedNetwork = network);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF1A5F56),
                                Color(0xFF2A6F66),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    const Color(0xFF1A5F56).withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      network,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildQRCodeSection(String address) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A5F56).withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF1A5F56)),
                        ),
                      ),
                    )
                  : address.isNotEmpty
                      ? QrImageView(
                          data: address,
                          size: 200,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        )
                      : Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: Text(
                              "عذراً، لا يوجد عنوان متاح",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_2,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "امسح الرمز أو انسخ العنوان",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(String address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A5F56).withOpacity(0.2),
            const Color(0xFF2A6F66).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "عنوان المحفظة",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    address.isNotEmpty ? address : "جاري التحميل...",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap:
                      address.isNotEmpty ? () => _copyToClipboard(address) : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1A5F56),
                          Color(0xFF2A6F66),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.copy,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.yellow.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "الرجاء ارسال المبلغ كاملاً ${price} ثم الضغط علي قمت بالدفع والتواصل مع المطور للتفعيل المباشر في اقل من دقيقه",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A5F56).withOpacity(0.2),
            const Color(0xFF2A6F66).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: hasPaid,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => hasPaid = value ?? false);
              },
              checkColor: Colors.white,
              fillColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Color(0xFF1A5F56);
                  }
                  return Colors.transparent;
                },
              ),
              side: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "✅ قمت بأرسال المبلغ,",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String contactLink) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: hasPaid
            ? () {
                HapticFeedback.heavyImpact();
                _launchUrl(contactLink);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: hasPaid
                ? const LinearGradient(
                    colors: [
                      Color(0xFF1A5F56),
                      Color(0xFF2A6F66),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.3),
                      Colors.grey.withOpacity(0.2),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: hasPaid
                ? [
                    BoxShadow(
                      color: const Color(0xFF1A5F56).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.telegram,
                  color: hasPaid ? Colors.white : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "تواصل للتفعيل",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: hasPaid ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// رسام التأثيرات المجمع
class CombinedEffectsPainter extends CustomPainter {
  final double waveValue;
  final double particleValue;
  final double glowValue;

  CombinedEffectsPainter(this.waveValue, this.particleValue, this.glowValue);

  @override
  void paint(Canvas canvas, Size size) {
    _drawWaves(canvas, size);
    _drawParticles(canvas, size);
    _drawGlow(canvas, size);
  }

  void _drawWaves(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // موجة علوية
    final path1 = Path();
    path1.moveTo(0, size.height * 0.15);

    for (double x = 0; x <= size.width; x += 8) {
      final y = size.height * 0.15 +
          sin((x / size.width * 4 * pi) + (waveValue * 2 * pi)) * 25;
      path1.lineTo(x, y);
    }

    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();

    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF1A5F56).withOpacity(0.4),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.25));

    canvas.drawPath(path1, paint);

    // موجة سفلية
    final path2 = Path();
    path2.moveTo(0, size.height);
    path2.lineTo(0, size.height * 0.85);

    for (double x = 0; x <= size.width; x += 8) {
      final y = size.height * 0.85 +
          sin((x / size.width * 3 * pi) + (waveValue * 2 * pi) + pi) * 35;
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.close();

    paint.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        const Color(0xFF0A4F46).withOpacity(0.5),
        Colors.transparent,
      ],
    ).createShader(
        Rect.fromLTWH(0, size.height * 0.75, size.width, size.height * 0.25));

    canvas.drawPath(path2, paint);
  }

  void _drawParticles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = Random(42);

    // جسيمات كبيرة متوهجة
    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1.5;

      final offsetX = sin(particleValue * 2 * pi + i * 0.4) * 25;
      final offsetY = cos(particleValue * 1.8 * pi + i * 0.3) * 18;

      final opacity = (sin(particleValue * 3 * pi + i) + 1) / 5 + 0.08;

      // توهج خارجي
      paint.shader = RadialGradient(
        colors: [
          Colors.cyan.withOpacity(opacity * 0.8),
          Colors.blue.withOpacity(opacity * 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(x + offsetX, y + offsetY),
        radius: radius * 2.5,
      ));

      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius * 2.5,
        paint,
      );

      // النواة
      paint.shader = null;
      paint.color = Colors.white.withOpacity(opacity * 1.2);
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius * 0.8,
        paint,
      );
    }

    // جسيمات صغيرة سريعة
    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.4;

      final offsetX = sin(particleValue * 5 * pi + i) * 40;
      final offsetY = cos(particleValue * 4 * pi + i) * 25;

      final opacity = (sin(particleValue * 7 * pi + i) + 1) / 8 + 0.03;

      paint.color = const Color(0xFF1A5F56).withOpacity(opacity);
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }
  }

  void _drawGlow(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // توهج في الزوايا
    final corners = [
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];

    for (int i = 0; i < corners.length; i++) {
      final opacity = (sin(glowValue * 2 * pi + i * pi / 2) + 1) / 12;

      paint.shader = RadialGradient(
        colors: [
          Colors.orange.withOpacity(opacity * 0.8),
          Colors.yellow.withOpacity(opacity * 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: corners[i],
        radius: 150,
      ));

      canvas.drawCircle(corners[i], 150, paint);
    }

    // توهج مركزي
    final centerOpacity = (sin(glowValue * pi * 1.5) + 1) / 15;
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF1A5F56).withOpacity(centerOpacity),
        const Color(0xFF2A6F66).withOpacity(centerOpacity * 0.6),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width * 0.5,
    ));

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.5,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}