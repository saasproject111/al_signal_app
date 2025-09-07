import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/services/crypto_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// استيراد الويدجتس الجديدة
import 'package:my_app/widgets/animated_background.dart';
import 'package:my_app/widgets/premium_glass_card.dart';
import 'package:my_app/widgets/premium_vip_banner.dart';
import 'package:my_app/widgets/premium_currency_card.dart';
import 'package:my_app/widgets/premium_social_button.dart';
import 'package:my_app/widgets/premium_info_cards.dart';

class PremiumHomePage extends StatefulWidget {
  const PremiumHomePage({super.key});

  @override
  State<PremiumHomePage> createState() => _PremiumHomePageState();
}

class _PremiumHomePageState extends State<PremiumHomePage> with TickerProviderStateMixin {
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
  late AnimationController _welcomeController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _bannerGlowAnimation;
  late Animation<double> _welcomeAnimation;
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
    _fetchPrices();
  }
  
  // --- دوال الإعداد والتشغيل ---
  void _setupAnimations() {
    _pulseAnimationController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 1)
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.7, 
      end: 1.0
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController, 
      curve: Curves.easeInOut
    ));
    
    _bannerGlowController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 500)
    );
    
    _bannerGlowAnimation = ColorTween(
      begin: Colors.white.withOpacity(0.2), 
      end: Colors.yellow[700]
    ).animate(CurvedAnimation(
      parent: _bannerGlowController, 
      curve: Curves.easeIn
    ));
    
    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _welcomeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _welcomeController,
      curve: Curves.elasticOut,
    ));
    
    _welcomeController.forward();
  }
  
  void _setDailyGoals() {
    final random = Random();
    _dailyTradeTarget = 230 + random.nextInt(41);
    _dailyProfitRatio = 0.90 + random.nextDouble() * 0.05;
  }

  void _setupTimers() {
    _numbersTimer = Timer.periodic(const Duration(seconds: 3), (timer) { 
      _updateNumbers(); 
    });
    _priceTimer = Timer.periodic(const Duration(minutes: 2), (timer) { 
      _fetchPrices(); 
    });
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
        if(mounted) setState(() { 
          _currentVipMessage = _vipMessages[Random().nextInt(_vipMessages.length)]; 
        });
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
      setState(() { 
        _currentDay = now.day; 
        _setDailyGoals(); 
      });
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح الرابط'))
        );
      }
    }
  }

  @override
  void dispose() {
    _numbersTimer?.cancel();
    _bannerTimer?.cancel();
    _priceTimer?.cancel();
    _pulseAnimationController.dispose();
    _bannerGlowController.dispose();
    _welcomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String userName = FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ?? 'المستخدم';
    
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildPremiumAppBar(),
        floatingActionButton: _buildPremiumFAB(),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildWelcomeSection(userName),
                const SizedBox(height: 30),
                PremiumVipBanner(
                  message: _currentVipMessage,
                  glowController: _bannerGlowController,
                  glowAnimation: _bannerGlowAnimation,
                ),
                const SizedBox(height: 40),
                _buildInfoCards(),
                const SizedBox(height: 40),
                _buildCurrencySection(),
                const SizedBox(height: 50),
                _buildSocialSection(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar() {
    return AppBar(
      title: const Text(
        'الرئيسية - HOME',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.black54,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumFAB() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          _launchURL('https://t.me/m/FIrEmovvOTU0');
        },
        backgroundColor: Colors.cyan,
        elevation: 0,
        child: const Icon(
          Icons.support_agent,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(String userName) {
    return AnimatedBuilder(
      animation: _welcomeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _welcomeAnimation.value,
          child: PremiumGlassCard(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              children: [
                Text(
                  'أهلاً وسهلاً',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.cyan,
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black54,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCards() {
    final blinkingDot = ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.greenAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.8),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );

    return PremiumInfoCards(
      winTrades: _winTrades,
      lossTrades: _lossTrades,
      activeUsers: _activeUsers,
      blinkingDot: blinkingDot,
    );
  }

  Widget _buildCurrencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'أشهر العملات',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 5.0,
                color: Colors.black54,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        PremiumCurrencyCard(
          iconPath: 'assets/btc_logo.png',
          currency: 'BTC',
          price: _btcPrice,
          chartColor: Colors.orange,
        ),
        const SizedBox(height: 20),
        PremiumCurrencyCard(
          iconPath: 'assets/eth_logo.png',
          currency: 'ETH',
          price: _ethPrice,
          chartColor: Colors.lightBlueAccent,
        ),
        const SizedBox(height: 20),
        PremiumCurrencyCard(
          iconPath: 'assets/usdt_logo.png',
          currency: 'USDT',
          price: _usdtPrice,
          chartColor: Colors.greenAccent,
        ),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'تابعنا على',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 5.0,
                color: Colors.black54,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PremiumSocialButton(
          label: 'YOUTUBE CHANNEL',
          iconAsset: 'assets/youtube_icon.png',
          gradient: const LinearGradient(
            colors: [Color(0xFFff4757), Color(0xFFff6b81)],
          ),
          onPressed: () {
            _launchURL('https://www.youtube.com/@ALPASHMO7ASB');
          },
        ),
        const SizedBox(height: 20),
        PremiumSocialButton(
          label: 'TELEGRAM GROUP',
          iconAsset: 'assets/telegram_icon.png',
          gradient: const LinearGradient(
            colors: [Color(0xFF2497d2), Color(0xFF34ace0)],
          ),
          onPressed: () {
            _launchURL('https://t.me/ALPASHMO7ASB_TEAM');
          },
        ),
        const SizedBox(height: 20),
        PremiumSocialButton(
          label: 'INSTAGRAM PAGE',
          iconAsset: 'assets/instagram_icon.png',
          gradient: const LinearGradient(
            colors: [Color(0xFF833ab4), Color(0xFFfd1d1d), Color(0xFFfcb045)],
          ),
          onPressed: () {
            _launchURL('https://www.instagram.com/alpashmo7asb?igsh=MWtzYzM1aWk2Mm82MQ==');
          },
        ),
      ],
    );
  }
}