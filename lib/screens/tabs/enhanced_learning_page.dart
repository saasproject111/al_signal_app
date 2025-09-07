import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/subscription_page.dart';
import 'package:my_app/widgets/animated_background.dart';
import 'package:my_app/widgets/premium_card.dart';
import 'package:my_app/widgets/animated_question_card.dart';
import 'package:url_launcher/url_launcher.dart';

// --- نماذج البيانات (نفس الكود الأصلي) ---
class Lecture {
  final String title;
  final String videoId;
  Lecture({required this.title, required this.videoId});
  factory Lecture.fromMap(Map<String, dynamic> data) {
    return Lecture(title: data['title'] ?? 'N/A', videoId: data['videoId'] ?? '');
  }
}

class LearningSection {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Lecture> lectures;
  final bool isVip;
  LearningSection({required this.title, required this.subtitle, required this.icon, required this.lectures, this.isVip = false});
  factory LearningSection.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    IconData _getIconFromString(String iconName) {
      switch (iconName) {
        case 'bar_chart': return Icons.bar_chart;
        case 'psychology': return Icons.psychology;
        case 'candlestick_chart': return Icons.candlestick_chart;
        case 'timeline': return Icons.timeline;
        case 'star': return Icons.star;
        default: return Icons.school;
      }
    }
    var lecturesData = data['lectures'] as List<dynamic>? ?? [];
    List<Lecture> lecturesList = lecturesData.map((lecture) => Lecture.fromMap(lecture)).toList();
    return LearningSection(
      title: data['title'] ?? 'N/A',
      subtitle: data['subtitle'] ?? '',
      icon: _getIconFromString(data['icon_name'] ?? ''),
      lectures: lecturesList,
      isVip: data['isVip'] ?? false,
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  Question({required this.text, required this.options, required this.correctAnswerIndex});
}

// --- الصفحة الرئيسية المحسنة ---
class EnhancedLearningPage extends StatefulWidget {
  const EnhancedLearningPage({super.key});
  @override
  State<EnhancedLearningPage> createState() => _EnhancedLearningPageState();
}

class _EnhancedLearningPageState extends State<EnhancedLearningPage> {
  // متغيرات لحالة الاختبار (نفس المنطق الأصلي)
  List<Question> _allQuestions = [];
  List<Question> _displayedQuestions = [];
  Map<int, int> _userAnswers = {};
  bool _showResults = false;
  int _correctAnswersCount = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAllQuestions();
    _scrollController.addListener(_onScroll);
  }

  void _loadAllQuestions() {
    // نفس الكود الأصلي للأسئلة
    _allQuestions = [
      Question(text: 'ما هو أفضل وصف لنمط "المطرقة" (Hammer) في الشموع اليابانية؟', options: ['شمعة هبوطية قوية', 'شمعة صعودية ذات فتيل سفلي طويل', 'شمعة بدون فتائل', 'نمط استمراري'], correctAnswerIndex: 1),
      Question(text: 'أي من المؤشرات التالية يقيس "زخم" السوق؟', options: ['المتوسط المتحرك (Moving Average)', 'بولينجر باندز (Bollinger Bands)', 'مؤشر القوة النسبية (RSI)', 'مستويات فيبوناتشي'], correctAnswerIndex: 2),
      Question(text: 'ماذا يمثل "الدعم" (Support) في التحليل الفني؟', options: ['مستوى سعر من المرجح أن يرتد منه السعر لأعلى', 'مستوى سعر من المرجح أن يرتد منه السعر لأسفل', 'أعلى سعر وصل له الأصل', 'أقل سعر وصل له الأصل'], correctAnswerIndex: 0),
      Question(text: 'ما معنى مصطلح الفوركس (Forex)؟', options: ['تداول العملات الأجنبية', 'الأسهم الأمريكية', 'المشتقات المالية', 'السلع فقط'], correctAnswerIndex: 0),
      Question(text: 'ما هو حجم العقد القياسي (Standard Lot) في الفوركس؟', options: ['100 وحدة', '1000 وحدة', '10000 وحدة', '100000 وحدة'], correctAnswerIndex: 3),
      Question(text: 'ما هي الرافعة المالية (Leverage)؟', options: ['أداة للتحليل الفني', 'إمكانية التداول برأس مال أكبر من الرصيد الفعلي', 'نوع من المؤشرات', 'طريقة لإدارة رأس المال'], correctAnswerIndex: 1),
      Question(text: 'ماذا يعني مصطلح "Margin Call"؟', options: ['ربح إضافي', 'طلب إيداع أموال إضافية بسبب الخسارة', 'إغلاق الصفقة تلقائياً عند الربح', 'رسوم التداول'], correctAnswerIndex: 1),
      Question(text: 'أي من هذه الشموع تعكس هبوطاً محتملاً؟', options: ['شمعة دوجي', 'شمعة الرجل المشنوق (Hanging Man)', 'شمعة المطرقة', 'شمعة بيضاء طويلة'], correctAnswerIndex: 1),
      Question(text: 'ما هي وظيفة مؤشر البولنجر باندز (Bollinger Bands)؟', options: ['قياس حجم السوق', 'تحديد مناطق التشبع الشرائي والبيعي', 'إظهار الترند فقط', 'حساب الفوليوم'], correctAnswerIndex: 1),
      Question(text: 'في التداول الثنائي (Binary Options)، ما أقصى خسارة ممكنة في صفقة؟', options: ['10%', '50%', '100%', 'لا يوجد خسارة'], correctAnswerIndex: 2),
      Question(text: 'ما الفرق الأساسي بين الفوركس والخيارات الثنائية؟', options: ['الفوركس أكثر خطورة', 'البيناري له وقت انتهاء محدد بينما الفوركس لا', 'البيناري بدون رأس مال', 'لا يوجد فرق'], correctAnswerIndex: 1),
      Question(text: 'ما هو "Take Profit"؟', options: ['أمر لإغلاق الصفقة عند خسارة معينة', 'أمر لإغلاق الصفقة عند ربح محدد مسبقاً', 'زيادة حجم العقد', 'أداة للتحليل'], correctAnswerIndex: 1),
      Question(text: 'أي من الأزواج التالية يعتبر من العملات الرئيسية (Major Pairs)؟', options: ['USD/JPY', 'USD/EGP', 'GBP/ZAR', 'AUD/MXN'], correctAnswerIndex: 0),
      Question(text: 'ما معنى مصطلح "Pip" في الفوركس؟', options: ['وحدة قياس أصغر تغير في السعر', 'نوع من المؤشرات', 'سعر الإغلاق', 'اسم شمعة'], correctAnswerIndex: 0),
      Question(text: 'ماذا يمثل "المقاومة" (Resistance)؟', options: ['منطقة يتوقع أن يرتد السعر منها لأسفل', 'أعلى سعر في اليوم', 'مستوى وقف الخسارة', 'متوسط السعر'], correctAnswerIndex: 0),
      Question(text: 'ما هو التحليل الأساسي؟', options: ['الاعتماد على الأخبار والاقتصاد', 'الاعتماد على الرسم البياني', 'استخدام الشموع فقط', 'استخدام خطوط الترند فقط'], correctAnswerIndex: 0),
      Question(text: 'في إدارة رأس المال، ما النسبة المثالية للمخاطرة في الصفقة الواحدة؟', options: ['1-2% من رأس المال', '10% من رأس المال', '50% من رأس المال', '100% من رأس المال'], correctAnswerIndex: 0),
      Question(text: 'ماذا يعني مصطلح "Overbought"؟', options: ['تشبع بيعي', 'تشبع شرائي', 'اتجاه صاعد قوي', 'سوق هابط'], correctAnswerIndex: 1),
      Question(text: 'أي إطار زمني يستخدم عادة للتداول السريع (Scalping)؟', options: ['شهري', 'يومي', 'خمس دقائق', 'أسبوعي'], correctAnswerIndex: 2),
      Question(text: 'ما وظيفة مؤشر الموفنج أفريج (Moving Average)؟', options: ['تحديد الاتجاه العام', 'قياس التشبع الشرائي', 'توقع الأخبار', 'إظهار مستويات الدعم'], correctAnswerIndex: 0),
      Question(text: 'ماذا يحدث إذا ارتفع الدولار أمام اليورو؟', options: ['زوج EUR/USD يهبط', 'زوج EUR/USD يصعد', 'لا يتأثر الزوج', 'يرتفع معاً'], correctAnswerIndex: 0),
      Question(text: 'أي نوع من الأوامر يغلق الصفقة تلقائياً عند خسارة محددة؟', options: ['Take Profit', 'Stop Loss', 'Buy Limit', 'Sell Stop'], correctAnswerIndex: 1),
      Question(text: 'ما معنى مصطلح Hedging؟', options: ['فتح صفقة عكسية لحماية الصفقة الأصلية', 'مضاعفة حجم العقد', 'زيادة الرافعة', 'التحليل الأساسي'], correctAnswerIndex: 0),
      Question(text: 'أي من هذه الاستراتيجيات تعتبر آمنة نسبياً؟', options: ['Martingale', 'إدارة رأس المال 2%', 'All-in', 'زيادة المخاطرة'], correctAnswerIndex: 1),
      Question(text: 'ما هو الفوليوم (Volume)؟', options: ['عدد الصفقات المنفذة', 'قيمة الربح', 'مستوى الدعم', 'الموفنج أفريج'], correctAnswerIndex: 0),
      Question(text: 'أي الشموع التالية تدل على الحيرة في السوق؟', options: ['Doji', 'Hammer', 'Engulfing', 'Marubozu'], correctAnswerIndex: 0),
      Question(text: 'ما هي ميزة حساب تجريبي (Demo Account)؟', options: ['التداول بدون أموال حقيقية', 'ربح مضمون', 'لا خسارة', 'أرباح أكبر'], correctAnswerIndex: 0),
      Question(text: 'ما هو السبريد (Spread)؟', options: ['الفرق بين سعر البيع والشراء', 'الرافعة المالية', 'وقف الخسارة', 'نوع شمعة'], correctAnswerIndex: 0),
      Question(text: 'أي الأزواج التالية يسمى بالـ "Cable"؟', options: ['GBP/USD', 'EUR/USD', 'USD/JPY', 'USD/CAD'], correctAnswerIndex: 0),
      Question(text: 'ما معنى مصطلح Liquidity؟', options: ['السيولة في السوق', 'نوع من العقود', 'وقف الخسارة', 'التذبذب'], correctAnswerIndex: 0),
      Question(text: 'في البيناري أوبشن، إذا توقعت أن السعر سيهبط تختار؟', options: ['Call', 'Put', 'Hold', 'Stop'], correctAnswerIndex: 1),
    ];
    _displayedQuestions = _allQuestions.take(3).toList();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreQuestions();
    }
  }

  void _loadMoreQuestions() {
    if (_displayedQuestions.length < _allQuestions.length) {
      if(mounted) {
        setState(() {
          int nextIndex = _displayedQuestions.length;
          _displayedQuestions.add(_allQuestions[nextIndex]);
        });
      }
    }
  }

  void _submitQuiz() {
    _correctAnswersCount = 0;
    _userAnswers.forEach((questionIndex, selectedAnswerIndex) {
      if (_allQuestions[questionIndex].correctAnswerIndex == selectedAnswerIndex) {
        _correctAnswersCount++;
      }
    });
    if(mounted) {
      setState(() { _showResults = true; });
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal.withOpacity(0.3),
                    Colors.cyan.withOpacity(0.2),
                    Colors.blue.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة النتيجة
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _correctAnswersCount >= _allQuestions.length * 0.7
                          ? Colors.green
                          : _correctAnswersCount >= _allQuestions.length * 0.5
                          ? Colors.orange
                          : Colors.red,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: (_correctAnswersCount >= _allQuestions.length * 0.7
                              ? Colors.green
                              : _correctAnswersCount >= _allQuestions.length * 0.5
                              ? Colors.orange
                              : Colors.red).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _correctAnswersCount >= _allQuestions.length * 0.7
                          ? Icons.emoji_events
                          : _correctAnswersCount >= _allQuestions.length * 0.5
                          ? Icons.thumb_up
                          : Icons.refresh,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // النتيجة
                  Text(
                    'نتيجتك',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$_correctAnswersCount / ${_allQuestions.length}',
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _correctAnswersCount >= _allQuestions.length * 0.7
                        ? 'ممتاز! أداء رائع 🎉'
                        : _correctAnswersCount >= _allQuestions.length * 0.5
                        ? 'جيد! يمكنك التحسن 👍'
                        : 'تحتاج للمزيد من المراجعة 📚',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  // أزرار الإجراءات
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _retakeQuiz();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'إعادة المحاولة',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'موافق',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _retakeQuiz() {
    setState(() {
      _userAnswers = {};
      _showResults = false;
      _correctAnswersCount = 0;
      _displayedQuestions = _allQuestions.take(3).toList();
    });
  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: AppBar(
              title: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.tealAccent, Colors.cyanAccent, Colors.white],
                ).createShader(bounds),
                child: const Text(
                  'التــــــعلم - LEARNING',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
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
                      Colors.teal.withOpacity(0.3),
                      Colors.cyan.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: TabBar(
                    labelColor: Colors.tealAccent,
                    unselectedLabelColor: Colors.white70,
                    indicator: BoxDecoration(
                      color: Colors.teal.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_filled, size: 20),
                            SizedBox(width: 8),
                            Text('المحاضرات', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.quiz, size: 20),
                            SizedBox(width: 8),
                            Text('الاختبار', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              const EnhancedLecturesView(),
              _buildEnhancedQuizView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedQuizView() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 100),
      children: [
        if (_showResults) _buildEnhancedResultHeader(),
        ...List.generate(_displayedQuestions.length, (index) {
          return AnimatedQuestionCard(
            questionText: _displayedQuestions[index].text,
            options: _displayedQuestions[index].options,
            selectedAnswer: _userAnswers[index],
            correctAnswer: _displayedQuestions[index].correctAnswerIndex,
            showResults: _showResults,
            onAnswerSelected: (selectedIndex) {
              setState(() {
                _userAnswers[index] = selectedIndex;
              });
            },
            questionIndex: index,
          );
        }),
        if (!_showResults && _displayedQuestions.length == _allQuestions.length)
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: PremiumCard(
              child: Container(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _userAnswers.length == _allQuestions.length ? _submitQuiz : null,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.cyan],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Center(
                      child: Text(
                        'عرض النتيجة 🎯',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEnhancedResultHeader() {
    return PremiumCard(
      backgroundColor: Colors.teal.withOpacity(0.2),
      borderColor: Colors.tealAccent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.tealAccent,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.tealAccent.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.assessment,
                color: Colors.black,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'نتيجتك النهائية',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctAnswersCount / ${_allQuestions.length}',
              style: const TextStyle(
                color: Colors.tealAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retakeQuiz,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'إعادة الاختبار',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ويدجت المحاضرات المحسن ---
class EnhancedLecturesView extends StatefulWidget {
  const EnhancedLecturesView({super.key});

  @override
  State<EnhancedLecturesView> createState() => _EnhancedLecturesViewState();
}

class _EnhancedLecturesViewState extends State<EnhancedLecturesView> {

  Future<void> _launchURL(String videoId) async {
    final Uri uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _fetchUserVipStatus(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
            ),
          );
        }
        final bool isUserVip = userSnapshot.data ?? false;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('learning_sections').orderBy('timestamp').snapshots(),
          builder: (context, sectionsSnapshot) {
            if (sectionsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                ),
              );
            }
            if (!sectionsSnapshot.hasData) {
              return const Center(
                child: Text(
                  'لا يوجد محتوى',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }
            final sections = sectionsSnapshot.data!.docs.map((doc) => LearningSection.fromFirestore(doc)).toList();
            return ListView(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 20),
              children: [
                _buildEnhancedHeader(),
                const SizedBox(height: 30),
                ...sections.asMap().entries.map((entry) {
                  int index = entry.key;
                  LearningSection section = entry.value;
                  return _buildEnhancedSectionCard(context, section, isUserVip, index);
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _fetchUserVipStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return false;
    return userDoc.data()?['isVip'] ?? false;
  }

  Widget _buildEnhancedHeader() {
    return PremiumCard(
      backgroundColor: Colors.teal.withOpacity(0.2),
      borderColor: Colors.tealAccent.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // أيقونة التعلم المتوهجة
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.tealAccent, Colors.cyan],
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.tealAccent.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.school,
                size: 50,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // العنوان الرئيسي
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Colors.tealAccent, Colors.cyan],
              ).createShader(bounds),
              child: const Text(
                'خطوتك الأولى في عالم التداول',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '"بيناري - فوركس"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.tealAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.3),
                    Colors.red.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.5),
                ),
              ),
              child: const Text(
                'هذا الكورس كفيل يحولك من مبتدأ الى محترف في اقل من شهر',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSectionCard(BuildContext context, LearningSection section, bool isUserVip, int index) {
    final bool isLocked = section.isVip && !isUserVip;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: PremiumCard(
        isVip: section.isVip,
        backgroundColor: isLocked
            ? Colors.grey.withOpacity(0.2)
            : section.isVip
            ? Colors.amber.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        borderColor: isLocked
            ? Colors.grey.withOpacity(0.5)
            : section.isVip
            ? Colors.yellow.withOpacity(0.7)
            : Colors.teal.withOpacity(0.5),
        onTap: isLocked
            ? () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SubscriptionPage())
        )
            : null,
        child: isLocked ? _buildLockedSection(section) : _buildUnlockedSection(section),
      ),
    );
  }

  Widget _buildLockedSection(LearningSection section) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.lock,
              color: Colors.grey,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'محتوى حصري للمشتركين',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.yellow),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.yellow, size: 16),
                SizedBox(width: 4),
                Text(
                  'VIP',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedSection(LearningSection section) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        expansionTileTheme: const ExpansionTileThemeData(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white70,
        ),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: section.isVip
                  ? [Colors.yellow, Colors.orange]
                  : [Colors.teal, Colors.cyan],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: (section.isVip ? Colors.yellow : Colors.teal).withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            section.icon,
            color: Colors.black,
            size: 25,
          ),
        ),
        title: Text(
          section.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          section.subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (section.isVip)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.yellow),
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more, color: Colors.white),
          ],
        ),
        children: section.lectures.asMap().entries.map((entry) {
          int lectureIndex = entry.key;
          Lecture lecture = entry.value;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              title: Text(
                lecture.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'المحاضرة ${lectureIndex + 1}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              onTap: () => _launchURL(lecture.videoId),
              trailing: const Icon(
                Icons.open_in_new,
                color: Colors.white70,
                size: 20,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}