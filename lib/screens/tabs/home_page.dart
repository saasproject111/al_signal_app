import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/services/crypto_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // --- متغيرات الحالة الديناميكية ---
  int _activeUsers = 7500;
  int _winTrades = 0;
  int _lossTrades = 0;
  String _btcPrice = 'Loading...';
  String _ethPrice = 'Loading...';
  String _usdtPrice = 'Loading...';
  String _currentVipMessage = '...';
  List<String> _vipMessages = [];

  // --- أدوات ومتحكمات ---
  Timer? _numbersTimer, _bannerTimer, _priceTimer;
  late AnimationController _pulseAnimationController, _bannerGlowController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _bannerGlowAnimation;
  final CryptoService _cryptoService = CryptoService();
  final NumberFormat _priceFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
  final NumberFormat _usdtFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 4);

  // متغيرات لتحديد الهدف اليومي
  int _currentDay = DateTime.now().day;
  late double _dailyProfitRatio;
  late int _dailyTradeTarget;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setDailyGoals();
    _setupTimers();
    _loadVipMessages();
    _fetchPrices(); // جلب الأسعار عند بدء التشغيل
  }
  
  // --- دوال الإعداد والتشغيل ---
  void _setupAnimations() {
    _pulseAnimationController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut));
    _bannerGlowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _bannerGlowAnimation = ColorTween(begin: Colors.white.withOpacity(0.2), end: Colors.yellow[700]).animate(CurvedAnimation(parent: _bannerGlowController, curve: Curves.easeIn));
  }
  
  void _setDailyGoals() {
    final random = Random();
    _dailyTradeTarget = 230 + random.nextInt(41);
    _dailyProfitRatio = 0.90 + random.nextDouble() * 0.05;
  }

  void _setupTimers() {
    _numbersTimer = Timer.periodic(const Duration(seconds: 3), (timer) { _updateNumbers(); });
    _priceTimer = Timer.periodic(const Duration(minutes: 2), (timer) { _fetchPrices(); });
    _scheduleNextBannerUpdate();
  }

  Future<void> _loadVipMessages() async {
    try {
      final String messagesString = await rootBundle.loadString('assets/messages.txt');
      if(mounted) {
        setState(() {
          _vipMessages = messagesString.split('\n').where((line) => line.isNotEmpty).toList();
          _currentVipMessage = _vipMessages.isNotEmpty ? _vipMessages[Random().nextInt(_vipMessages.length)] : 'مرحبًا!';
        });
      }
    } catch (e) {
       if(mounted) setState(() { _currentVipMessage = 'مرحبًا!'; });
    }
  }

  void _scheduleNextBannerUpdate() {
    if (!mounted) return;
    final randomDuration = Duration(minutes: 4 + Random().nextInt(5));
    _bannerTimer = Timer(randomDuration, () {
      if (_vipMessages.isNotEmpty) {
        if(mounted) setState(() { _currentVipMessage = _vipMessages[Random().nextInt(_vipMessages.length)]; });
        _bannerGlowController.forward().then((_) => _bannerGlowController.reverse());
      }
      _scheduleNextBannerUpdate();
    });
  }

  // --- دوال جلب وتحديث البيانات ---
  Future<void> _fetchPrices() async {
    final prices = await _cryptoService.getPrices();
    if (mounted && prices.isNotEmpty) {
      setState(() {
        _btcPrice = _priceFormat.format(prices['bitcoin']['usd']);
        _ethPrice = _priceFormat.format(prices['ethereum']['usd']);
        _usdtPrice = _usdtFormat.format(prices['tether']['usd']);
      });
    }
  }

  void _updateNumbers() {
    final now = DateTime.now();
    if (now.day != _currentDay) {
      setState(() { _currentDay = now.day; _setDailyGoals(); });
    }
    final sineValue = sin((now.hour * 3600 + now.minute * 60 + now.second) / (24 * 3600) * 2 * pi);
    final baseUsers = 7000 + (sineValue * 2000);
    final randomChange = Random().nextInt(21) - 10;
    final progressOfDay = (now.hour * 3600 + now.minute * 60 + now.second) / (24 * 3600);
    final currentTotalTrades = (_dailyTradeTarget * progressOfDay);
    setState(() {
      _activeUsers = (baseUsers + randomChange).round();
      _winTrades = (currentTotalTrades * _dailyProfitRatio).round();
      _lossTrades = (currentTotalTrades * (1 - _dailyProfitRatio)).round();
    });
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح الرابط')));
    }
  }

  @override
  void dispose() {
    _numbersTimer?.cancel();
    _bannerTimer?.cancel();
    _priceTimer?.cancel();
    _pulseAnimationController.dispose();
    _bannerGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String userName = FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ?? 'المستخدم';
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0A4F46), Colors.black], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('الرئيسية - HOME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _launchURL('https://t.me/m/FIrEmovvOTU0'); // !! استبدل بالرابط الصحيح !!
          },
          backgroundColor: Colors.cyan,
          child: const Icon(Icons.support_agent, color: Colors.white),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text('اهلا بك .. $userName', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildLatestVipBanner(),
                const SizedBox(height: 30),
                _buildInfoCards(),
                const SizedBox(height: 30),
                const Text('اشهر العملات', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildCurrencyCard(iconPath: 'assets/btc_logo.png', currency: 'BTC', price: _btcPrice, chartColor: Colors.orange),
                const SizedBox(height: 16),
                _buildCurrencyCard(iconPath: 'assets/eth_logo.png', currency: 'ETH', price: _ethPrice, chartColor: Colors.lightBlueAccent),
                const SizedBox(height: 16),
                _buildCurrencyCard(iconPath: 'assets/usdt_logo.png', currency: 'USDT', price: _usdtPrice, chartColor: Colors.greenAccent),
                const SizedBox(height: 40),
                _buildSocialButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- تم تعديل هذه الويدجت بالكامل ---
  Widget _buildInfoCards() {
    final blinkingDot = ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.greenAccent,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 5, spreadRadius: 1)],
        ),
      ),
    );
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWinLossItem(winCount: _winTrades, lossCount: _lossTrades, leadingWidget: blinkingDot),
                _buildInfoItem(title: 'عدد المستخدمين النشطين', value: _activeUsers.toString(), valueColor: Colors.greenAccent, leadingWidget: blinkingDot),
              ],
            ),
            const Divider(color: Colors.white24, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMarketStatus(title: 'OTC سوق', isOpen: true),
                _buildMarketStatus(title: 'السوق العالمي', isOpen: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // --- كل الويدجتس المساعدة الأخرى تبقى كما هي ---
  Widget _buildSocialButtons() {
    return Column(children: [
      _buildSocialButton(label: 'YOUTUBE CHANNEL', iconAsset: 'assets/youtube_icon.png', gradient: const LinearGradient(colors: [Color(0xFFff4757), Color(0xFFff6b81)]), onPressed: () { _launchURL('https://www.youtube.com/@ALPASHMO7ASB'); }),
      const SizedBox(height: 16),
      _buildSocialButton(label: 'TELEGRAM GROUP', iconAsset: 'assets/telegram_icon.png', gradient: const LinearGradient(colors: [Color(0xFF2497d2), Color(0xFF34ace0)]), onPressed: () { _launchURL('https://t.me/ALPASHMO7ASB_TEAM'); }),
      const SizedBox(height: 16),
      _buildSocialButton(label: 'INSTAGRAM PAGE', iconAsset: 'assets/instagram_icon.png', gradient: const LinearGradient(colors: [Color(0xFF833ab4), Color(0xFFfd1d1d), Color(0xFFfcb045)]), onPressed: () { _launchURL('https://www.instagram.com/alpashmo7asb?igsh=MWtzYzM1aWk2Mm82MQ=='); }),
    ]);
  }
  Widget _buildSocialButton({required String label, required String iconAsset, required Gradient gradient, required VoidCallback onPressed}) {
    return ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 5, shadowColor: Colors.black.withOpacity(0.5)), child: Ink(decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(30)), child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset(iconAsset, height: 28, width: 28), const SizedBox(width: 12), Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(blurRadius: 2.0, color: Colors.black38, offset: Offset(1, 1))]))]))));
  }
  Widget _buildLatestVipBanner() {
    return AnimatedBuilder(animation: _bannerGlowController, builder: (context, child) => ClipRRect(borderRadius: BorderRadius.circular(25.0), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(25.0), border: Border.all(color: _bannerGlowAnimation.value!, width: 1.5), boxShadow: [BoxShadow(color: _bannerGlowAnimation.value!, blurRadius: 10, spreadRadius: 2)]), child: child))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.star_border_purple500_outlined, color: Colors.yellow, size: 20), const SizedBox(width: 10), Expanded(child: Text(_currentVipMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center))]));
  }
  Widget _buildWinLossItem({required int winCount, required int lossCount, required Widget leadingWidget}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [leadingWidget, const SizedBox(width: 8), const Text("صفقات اليوم", style: TextStyle(color: Colors.white70, fontSize: 14))]), const SizedBox(height: 8), Row(children: [const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16), Text(" ${winCount.toString()} : WIN", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(width: 12), const Icon(Icons.cancel, color: Colors.redAccent, size: 16), Text(" ${lossCount.toString()} : LOSS", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))])]);
  }
  Widget _buildInfoItem({required String title, required String value, required Color valueColor, Widget? leadingWidget}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.center, children: [if (leadingWidget != null) leadingWidget, if (leadingWidget != null) const SizedBox(width: 8), Text(value, style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.bold))])]);
  }
  Widget _buildCurrencyCard({required String iconPath, required String currency, required String price, required Color chartColor}) {
    return _buildGlassCard(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Row(children: [Image.asset(iconPath, height: 40, errorBuilder: (c, e, s) => CircleAvatar(radius: 20, backgroundColor: Colors.white24, child: Text(currency[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(currency, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text(price, style: const TextStyle(color: Colors.white70, fontSize: 16))]), const Spacer(), SizedBox(width: 80, height: 40, child: CustomPaint(painter: _LineChartPainter(chartColor)))])));
  }
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(borderRadius: BorderRadius.circular(25.0), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(25.0), border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5)), child: child)));
  }
  Widget _buildMarketStatus({required String title, required bool isOpen}) {
    return Row(children: [Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)), const SizedBox(width: 8), Text(isOpen ? 'OPEN' : 'CLOSE', style: TextStyle(color: isOpen ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18))]);
  }
}
class _LineChartPainter extends CustomPainter {
  final Color lineColor;
  _LineChartPainter(this.lineColor);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = lineColor..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(0, size.height * 0.7)..quadraticBezierTo(size.width * 0.2, size.height * 0.3, size.width * 0.4, size.height * 0.6)..quadraticBezierTo(size.width * 0.6, size.height * 0.1, size.width * 0.8, size.height * 0.4)..quadraticBezierTo(size.width * 0.9, size.height * 0.7, size.width, size.height * 0.3);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

