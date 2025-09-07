import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/privacy_policy_page.dart';
import 'package:my_app/screens/subscription_page.dart';
import 'package:my_app/screens/terms_of_service_page.dart';

// استيراد الخلفية المتحركة
import 'package:my_app/widgets/animated_background.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  DocumentReference? get userRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  Future<void> _updateUserSetting(Map<String, dynamic> data) async {
    await userRef?.update(data);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground( // <<< الخلفية المتحركة
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'الإعدادات',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: userRef?.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'لا يمكن تحميل البيانات',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final userData =
                snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final String selectedPlatform = userData['platform'] ?? 'Quotex';
            final bool notificationsEnabled =
                userData['notificationsEnabled'] ?? true;

            final String savedCountryName = userData['country'] ?? 'Egypt';
            Country? foundCountry;
            try {
              foundCountry = CountryService().findByName(savedCountryName);
            } catch (e) {}
            Country selectedCountry =
                foundCountry ?? CountryService().findByCode('EG')!;

            return ListView(
              padding: const EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: 20,
              ),
              children: [
                _buildCustomizationSection(selectedCountry, selectedPlatform),
                const SizedBox(height: 24),
                _buildAccountSection(notificationsEnabled),
                const SizedBox(height: 24),
                _buildAboutSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomizationSection(Country country, String platform) {
    return _buildGlassCard(
      title: 'التخصيص',
      children: [
        _buildCountrySelector(country),
        const Divider(color: Colors.white12),
        _buildDropdownItem(
          icon: Icons.computer,
          label: 'المنصة',
          value: platform,
          items: ['Quotex', 'Binance', 'Bybit', 'أخرى'],
          onChanged: (newValue) {
            if (newValue != null) {
              _updateUserSetting({'platform': newValue});
            }
          },
        ),
      ],
    );
  }

  Widget _buildAccountSection(bool notificationsEnabled) {
    return _buildGlassCard(
      title: 'الحساب والإشعارات',
      children: [
        SwitchListTile(
          title: const Text(
            'إشعارات التوصيات الفورية',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          value: notificationsEnabled,
          onChanged: (bool value) {
            _updateUserSetting({'notificationsEnabled': value});
          },
          secondary:
              const Icon(Icons.notifications_active_outlined, color: Colors.white70),
          activeColor: Colors.tealAccent,
        ),
        const Divider(color: Colors.white12),
        _buildListItem(
          icon: Icons.star_purple500_outlined,
          text: 'إدارة الاشتراك',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SubscriptionPage()),
            );
          },
        ),
        const Divider(color: Colors.white12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
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
        _buildListItem(
          icon: Icons.description_outlined,
          text: 'شروط الخدمة',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
            );
          },
        ),
        const Divider(color: Colors.white12),
        _buildListItem(
          icon: Icons.privacy_tip_outlined,
          text: 'سياسة الخصوصية',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGlassCard({
    required String title,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25.0),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const Divider(height: 24, color: Colors.white24),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountrySelector(Country selectedCountry) {
    return ListTile(
      leading: const Icon(Icons.flag_outlined, color: Colors.white70),
      title: const Text('الدولة',
          style: TextStyle(fontSize: 16, color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${selectedCountry.flagEmoji} ${selectedCountry.name}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_drop_down, color: Colors.white70),
        ],
      ),
      onTap: () {
        showCountryPicker(
          context: context,
          countryListTheme: CountryListThemeData(
            backgroundColor: Colors.blueGrey[900],
            textStyle: const TextStyle(color: Colors.white),
            bottomSheetHeight: MediaQuery.of(context).size.height * 0.8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            inputDecoration: InputDecoration(
              hintText: 'ابحث عن دولتك',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          onSelect: (Country country) {
            _updateUserSetting({'country': country.name});
          },
        );
      },
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
          ),
          Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.blueGrey[800]),
            child: DropdownButton<String>(
              value: value,
              iconEnabledColor: Colors.white70,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              underline: const SizedBox(),
              items: items
                  .map<DropdownMenuItem<String>>(
                      (String val) => DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(text,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: Colors.white70),
      onTap: onTap,
    );
  }
}
