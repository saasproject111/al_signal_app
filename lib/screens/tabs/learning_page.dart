import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/subscription_page.dart';
import 'package:url_launcher/url_launcher.dart';

// --- نماذج البيانات ---

class Lecture {
  final String title;
  final String youtubeUrl;
  Lecture({required this.title, required this.youtubeUrl});

  factory Lecture.fromMap(Map<String, dynamic> data) {
    return Lecture(
      title: data['title'] ?? 'N/A',
      youtubeUrl: data['youtubeUrl'] ?? '',
    );
  }
}

class LearningSection {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Lecture> lectures;
  final bool isVip;

  LearningSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.lectures,
    this.isVip = false,
  });

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
    List<Lecture> lecturesList =
        lecturesData.map((lecture) => Lecture.fromMap(lecture)).toList();

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


// --- واجهة الصفحة ---

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  // متغيرات لحالة الاختبار
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
    // يمكنك لاحقًا جلب هذه الأسئلة من Firestore
    _allQuestions = [
      Question(
        text: 'ما هو أفضل وصف لنمط "المطرقة" (Hammer) في الشموع اليابانية؟',
        options: ['شمعة هبوطية قوية', 'شمعة صعودية ذات فتيل سفلي طويل', 'شمعة بدون فتائل', 'نمط استمراري'],
        correctAnswerIndex: 1,
      ),
      Question(
        text: 'أي من المؤشرات التالية يقيس "زخم" السوق؟',
        options: ['المتوسط المتحرك (Moving Average)', 'بولينجر باندز (Bollinger Bands)', 'مؤشر القوة النسبية (RSI)', 'مستويات فيبوناتشي'],
        correctAnswerIndex: 2,
      ),
       Question(
        text: 'ماذا يمثل "الدعم" (Support) في التحليل الفني؟',
        options: ['مستوى سعر من المرجح أن يرتد منه السعر لأعلى', 'مستوى سعر من المرجح أن يرتد منه السعر لأسفل', 'أعلى سعر وصل له الأصل', 'أقل سعر وصل له الأصل'],
        correctAnswerIndex: 0,
      ),
      // --- أضف المزيد من الأسئلة هنا ---
       Question(text: 'سؤال 4', options: ['أ', 'ب', 'ج', 'د'], correctAnswerIndex: 0),
       Question(text: 'سؤال 5', options: ['أ', 'ب', 'ج', 'د'], correctAnswerIndex: 1),
       Question(text: 'سؤال 6', options: ['أ', 'ب', 'ج', 'د'], correctAnswerIndex: 2),
       Question(text: 'سؤال 7', options: ['أ', 'ب', 'ج', 'د'], correctAnswerIndex: 3),
    ];
    // عرض أول 3 أسئلة
    _displayedQuestions = _allQuestions.take(3).toList();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreQuestions();
    }
  }

  void _loadMoreQuestions() {
    if (_displayedQuestions.length < _allQuestions.length) {
      setState(() {
        int nextIndex = _displayedQuestions.length;
        _displayedQuestions.add(_allQuestions[nextIndex]);
      });
    }
  }

  void _submitQuiz() {
    _correctAnswersCount = 0;
    _userAnswers.forEach((questionIndex, selectedAnswerIndex) {
      if (_allQuestions[questionIndex].correctAnswerIndex == selectedAnswerIndex) {
        _correctAnswersCount++;
      }
    });
    setState(() {
      _showResults = true;
    });
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
    return DefaultTabController(
      length: 2, // عدد التبويبات
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('التــــــعلم - LEARNING', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.tealAccent,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.tealAccent,
            indicatorWeight: 3.0,
            tabs: [
              Tab(text: 'المحاضرات'),
              Tab(text: 'الاختبار'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF0A4F46), Colors.black], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: TabBarView(
            children: [
              // --- محتوى تبويب المحاضرات ---
              LecturesView(),
              // --- محتوى تبويب الاختبار ---
              _buildQuizView(),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت لبناء واجهة الاختبار
  Widget _buildQuizView() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 150, left: 16, right: 16, bottom: 100),
      children: [
        if (_showResults) _buildResultHeader(),
        ...List.generate(_displayedQuestions.length, (index) {
          return _buildQuestionCard(_displayedQuestions[index], index);
        }),
        if (!_showResults && _displayedQuestions.length == _allQuestions.length)
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _submitQuiz,
              child: const Text('اختبر نتيجتك', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
      ],
    );
  }

  // ويدجت لعرض رأس النتيجة
  Widget _buildResultHeader() {
    return Card(
      color: Colors.black.withOpacity(0.3),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'نتيجتك: $_correctAnswersCount / ${_allQuestions.length}',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retakeQuiz,
              child: const Text('إعادة الاختبار'),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت لبناء بطاقة السؤال
  Widget _buildQuestionCard(Question question, int questionIndex) {
    return Card(
      color: Colors.black.withOpacity(0.25),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'السؤال ${questionIndex + 1}: ${question.text}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(question.options.length, (optionIndex) {
              bool isSelected = _userAnswers[questionIndex] == optionIndex;
              bool isCorrect = question.correctAnswerIndex == optionIndex;

              Color? tileColor;
              Icon? trailingIcon;

              if (_showResults) {
                if (isCorrect) {
                  tileColor = Colors.green.withOpacity(0.3);
                  trailingIcon = const Icon(Icons.check, color: Colors.green);
                } else if (isSelected && !isCorrect) {
                  tileColor = Colors.red.withOpacity(0.3);
                  trailingIcon = const Icon(Icons.close, color: Colors.red);
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected && !_showResults ? Border.all(color: Colors.tealAccent, width: 2) : null,
                ),
                child: ListTile(
                  title: Text(question.options[optionIndex], style: const TextStyle(color: Colors.white)),
                  onTap: _showResults ? null : () {
                    setState(() {
                      _userAnswers[questionIndex] = optionIndex;
                    });
                  },
                  trailing: trailingIcon,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// --- ويدجت المحاضرات (تم فصلها لتنظيم الكود) ---

class LecturesView extends StatelessWidget {
  const LecturesView({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _fetchUserVipStatus(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final bool isUserVip = userSnapshot.data ?? false;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('learning_sections').orderBy('timestamp').snapshots(),
          builder: (context, sectionsSnapshot) {
            if (sectionsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!sectionsSnapshot.hasData) {
              return const Center(child: Text('لا يوجد محتوى', style: TextStyle(color: Colors.white)));
            }
            final sections = sectionsSnapshot.data!.docs.map((doc) => LearningSection.fromFirestore(doc)).toList();
            return ListView(
              padding: const EdgeInsets.only(top: 150, left: 16, right: 16, bottom: 20),
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24, thickness: 1),
                const SizedBox(height: 10),
                ...sections.map((section) => _buildSectionCard(context, section, isUserVip)).toList(),
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
  
  Widget _buildHeader() {
    return Column(
      children: [
        const Text('خطوتك الأولى في عالم التداول “بيناري - فوركس”', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('هذا الكورس كفيل يحولك من مبتدأ الى محترف في اقل من شهر', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 20),
        Image.asset('assets/book_logo.png', height: 120, errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.school, size: 120, color: Colors.tealAccent);
        }),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, LearningSection section, bool isUserVip) {
    final bool isLocked = section.isVip && !isUserVip;
    final cardColor = section.isVip ? Colors.teal.withOpacity(0.3) : Colors.black.withOpacity(0.25);
    final iconColor = section.isVip ? Colors.yellow[700] : Colors.white;
    if (isLocked) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0), side: BorderSide(color: Colors.grey[800]!)),
        child: ListTile(
          leading: Icon(Icons.lock, color: Colors.grey[700]),
          title: Text(section.title, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.lineThrough)),
          subtitle: Text('محتوى حصري للمشتركين', style: TextStyle(color: Colors.grey[700])),
          trailing: Icon(Icons.star, color: Colors.yellow[800]),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SubscriptionPage()));
          },
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0), side: section.isVip ? BorderSide(color: Colors.yellow[700]!, width: 1.5) : BorderSide.none),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(section.icon, color: iconColor),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: Text(section.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(section.subtitle, style: const TextStyle(color: Colors.white70)),
        children: section.lectures.map((lecture) {
          return ListTile(
            leading: const Icon(Icons.play_circle_outline, color: Colors.tealAccent),
            title: Text(lecture.title, style: const TextStyle(color: Colors.white)),
            onTap: () => _launchURL(lecture.youtubeUrl),
          );
        }).toList(),
      ),
    );
  }
}