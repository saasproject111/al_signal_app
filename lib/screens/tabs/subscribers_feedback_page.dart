import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_app/widgets/animated_background.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscribersFeedbackPage extends StatefulWidget {
  const SubscribersFeedbackPage({super.key});

  @override
  State<SubscribersFeedbackPage> createState() => _SubscribersFeedbackPageState();
}

class _SubscribersFeedbackPageState extends State<SubscribersFeedbackPage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _fadeAnimation;

  // جلب المستخدم الحالي من Firebase
  final User? user = FirebaseAuth.instance.currentUser;

  // بيانات تجريبية: 30 تعليق واقعية (يوزر + صورة + لهجة مختلفة + وقت)
  final List<Map<String, String>> comments = [
    {
      "user": "noura_ksa",
      "image": "https://i.pravatar.cc/150?img=5",
      "text": "الخدمة تفتح النفس والله 👌 حسيت فيه مصداقية كبيرة.",
      "time": "منذ 5 ساعات"
    },
    {
      "user": "fahad_qtr",
      "image": "https://i.pravatar.cc/150?img=12",
      "text": "يعطيكم العافية، متابع معاكم من فترة وما قصرتوا 🌹.",
      "time": "منذ 10 ساعات"
    },
    {
      "user": "mohamed_eg",
      "image": "https://i.pravatar.cc/150?img=t53",
      "text": "بصراحة شغل نظيف جدا ونتايج حلوة أوي ✌️.",
      "time": "منذ 12 ساعة"
    },
    {
      "user": "amira_dz",
      "image": "https://i.pravatar.cc/150?img=30",
      "text": "يعطيكم الصحة، الخدمة هايلة بزاف 👏.",
      "time": "منذ يوم"
    },
    {
      "user": "turki_fx",
      "image": "https://i.pravatar.cc/150?img=15",
      "text": "والله ما توقعت الفايدة بهالشكل، مشكورين يا جماعة.",
      "time": "منذ يومين"
    },
    {
      "user": "rabee3_uae",
      "image": "https://i.pravatar.cc/150?img=6",
      "text": "مره ارتحت للخدمة، حسيت بالفرق من أول أسبوع 💯.",
      "time": "منذ 3 أيام"
    },
    {
      "user": "marwaa_eg",
      "image": "https://i.pravatar.cc/150?img=23",
      "text": "الخدمة ممتازة وفعلا مختلفة عن حاجات كتير جربتها قبل كده 👌.",
      "time": "منذ أسبوع"
    },
    {
      "user": "salima_dz",
      "image": "https://i.pravatar.cc/150?img=28",
      "text": "بصراحة حاجة تعجب، راني فرحانة بالنتيجة 🙌.",
      "time": "منذ أسبوع"
    },
    {
      "user": "abdullah_bh",
      "image": "https://i.pravatar.cc/150?img=18",
      "text": "الخدمة محترمة وأسلوب التعامل راقي 👏.",
      "time": "منذ أسبوعين"
    },
    {
      "user": "fatima_q8",
      "image": "https://i.pravatar.cc/150?img=10",
      "text": "من أرقى الخدمات اللي شفتها، الله يوفقكم 🌸.",
      "time": "منذ 3 أسابيع"
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _listAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // رأس الصفحة المحسن
            AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -50 * (1 - _headerAnimation.value)),
                  child: Opacity(
                    opacity: _headerAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.6),
                            Colors.deepPurple.withOpacity(0.4),
                            Colors.indigo.withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                            child: Column(
                              children: [
                                const Text(
                                  "آراء المشتركين",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // مربع كتابة تعليق محسن
            AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - _headerAnimation.value)),
                  child: Opacity(
                    opacity: _headerAnimation.value,
                    child: !_submitted ? _buildCommentBox() : _buildSubmittedMessage(),
                  ),
                );
              },
            ),

            // قائمة التعليقات المحسنة
            Expanded(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 600 + (index * 100)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(50 * (1 - value), 0),
                              child: Opacity(
                                opacity: value,
                                child: _buildPremiumCommentCard(comments[index], index),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, color: Colors.white, size: 28)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "شاركنا تجربتك المميزة ...",
                        hintStyle: TextStyle(
                          color: Colors.white60,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.8),
                        Colors.deepPurple.withOpacity(0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          _submitted = true;
                          _controller.clear();
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
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

  Widget _buildSubmittedMessage() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.2),
            Colors.teal.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.greenAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "سيتم مراجعة تعليقك ونشره قريباً",
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCommentCard(Map<String, String> comment, int index) {
    final isEven = index % 2 == 0;
    
    return Container(
      margin: EdgeInsets.only(
        bottom: 16,
        left: isEven ? 0 : 20,
        right: isEven ? 20 : 0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            // يمكن إضافة تفاعل هنا
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.06),
                  Colors.white.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.purple.withOpacity(0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(comment["image"]!),
                            radius: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.tealAccent.withOpacity(0.3),
                                          Colors.cyanAccent.withOpacity(0.2),
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      "@${comment["user"]}",
                                      style: const TextStyle(
                                        color: Colors.tealAccent,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.verified,
                                      color: Colors.amberAccent,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment["time"]!,
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        comment["text"]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.3),
                            Colors.deepPurple.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amberAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "عضو مميز",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}