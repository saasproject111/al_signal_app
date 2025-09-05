import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/subscription_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  // متغيرات الحالة
  Country? _selectedCountry;
  String? _selectedPlatform;
  bool _notificationsEnabled = true;

  // متحكمات الأنيميشن
  late AnimationController _entryAnimationController;
  late List<Animation<Offset>> _slideAnimations;

  // مرجع لقاعدة البيانات
  final userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideAnimations = List.generate(
      3, // عدد البطاقات
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entryAnimationController,
        curve: Interval(0.2 * index, 0.7 + 0.2 * index, curve: Curves.decelerate),
      )),
    );
  }
  
  // دالة لتحديث الإعدادات في Firestore
  Future<void> _updateUserSetting(Map<String, dynamic> data) async {
    await userRef.update(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0A4F46), Colors.black], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        // استخدام FutureBuilder لجلب الإعدادات الحالية للمستخدم
        child: FutureBuilder<DocumentSnapshot>(
          future: userRef.get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // بدء الأنيميشن بعد جلب البيانات
            _entryAnimationController.forward();

            // قراءة البيانات المحفوظة من Firestore
            final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            _selectedPlatform = userData['platform'] ?? 'Quotex';
            _notificationsEnabled = userData['notificationsEnabled'] ?? true;
            try {
              _selectedCountry = CountryService().findByName(userData['country'] ?? 'Egypt');
            } catch (e) {
              _selectedCountry = CountryService().findByCode('EG');
            }


            return ListView(
              padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 20),
              children: [
                _buildAnimatedCard(
                  animation: _slideAnimations[0],
                  child: _buildCustomizationSection(),
                ),
                const SizedBox(height: 24),
                _buildAnimatedCard(
                  animation: _slideAnimations[1],
                  child: _buildAccountSection(),
                ),
                const SizedBox(height: 24),
                 _buildAnimatedCard(
                  animation: _slideAnimations[2],
                  child: _buildAboutSection(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ويدجت مساعدة للأنيميشن
  Widget _buildAnimatedCard({required Animation<Offset> animation, required Widget child}) {
     return FadeTransition(
      opacity: CurvedAnimation(parent: _entryAnimationController, curve: Curves.easeIn),
      child: SlideTransition(
        position: animation,
        child: child,
      ),
    );
  }
  
  // ويدجت مساعدة للبطاقة الزجاجية
  Widget _buildGlassCard({required String title, required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(25.0),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const Divider(height: 24, color: Colors.white24),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // -- أقسام الإعدادات --

  Widget _buildCustomizationSection() {
    return _buildGlassCard(
      title: 'التخصيص',
      children: [
        // اختيار الدولة
         _buildCountrySelector(),
         const Divider(color: Colors.white10),
        // اختيار المنصة
        _buildDropdownItem(
          icon: Icons.computer,
          label: 'المنصة',
          value: _selectedPlatform!,
          items: ['Quotex', 'Binance', 'Bybit', 'أخرى'],
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() { _selectedPlatform = newValue; });
              _updateUserSetting({'platform': newValue});
            }
          },
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildGlassCard(
      title: 'الحساب والإشعارات',
      children: [
        // تفعيل الإشعارات
        SwitchListTile(
          title: const Text('إشعارات التوصيات الفورية', style: TextStyle(color: Colors.white, fontSize: 16)),
          value: _notificationsEnabled,
          onChanged: (bool value) {
            setState(() { _notificationsEnabled = value; });
            _updateUserSetting({'notificationsEnabled': value});
          },
          secondary: const Icon(Icons.notifications_active_outlined, color: Colors.white70),
          activeColor: Colors.tealAccent,
        ),
         const Divider(color: Colors.white10),
        // إدارة الاشتراك
        _buildListItem(
          icon: Icons.star_purple500_outlined,
          text: 'إدارة الاشتراك',
          onTap: () {
             Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SubscriptionPage()));
          }
        ),
        const Divider(color: Colors.white10),
        // عرض User ID
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.person_pin_outlined, color: Colors.white70),
              const SizedBox(width: 16),
              const Text("User ID:", style: TextStyle(color: Colors.white70)),
              const Spacer(),
              SelectableText(
                FirebaseAuth.instance.currentUser?.uid.substring(0, 8) ?? 'N/A',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildGlassCard(
      title: 'عن التطبيق',
      children: [
        _buildListItem(icon: Icons.description_outlined, text: 'شروط الخدمة', onTap: () {}),
        const Divider(color: Colors.white10),
        _buildListItem(icon: Icons.privacy_tip_outlined, text: 'سياسة الخصوصية', onTap: () {}),
      ],
    );
  }
  
  // -- ويدجتس مساعدة لعناصر القائمة --

  Widget _buildCountrySelector() {
    return InkWell(
      onTap: () {
        showCountryPicker(
          context: context,
          onSelect: (Country country) {
            setState(() { _selectedCountry = country; });
            _updateUserSetting({'country': country.name});
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(Icons.flag_outlined, color: Colors.white70),
            const SizedBox(width: 16),
            const Expanded(child: Text('الدولة', style: TextStyle(fontSize: 16, color: Colors.white))),
            Text('${_selectedCountry?.flagEmoji ?? ''} ${_selectedCountry?.name ?? ''}', style: const TextStyle(fontSize: 16, color: Colors.white)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownItem({required IconData icon, required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white))),
          Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.blueGrey[800]),
            child: DropdownButton<String>(
              value: value,
              iconEnabledColor: Colors.white70,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: items.map<DropdownMenuItem<String>>((String val) => DropdownMenuItem<String>(value: val, child: Text(val))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 16),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white))),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
