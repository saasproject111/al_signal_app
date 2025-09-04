import 'package:country_picker/country_picker.dart'; // تم تصحيح هذا السطر
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Country? _selectedCountry;
  String _selectedPlatform = 'Quotex';
  String _selectedTimezone = 'UTC-11:00';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final countryCode = prefs.getString('countryCode');
      if (countryCode != null) {
        _selectedCountry = CountryService().findByCode(countryCode);
      } else {
        _selectedCountry = CountryService().findByCode('EG');
      }
      _selectedPlatform = prefs.getString('platform') ?? 'Quotex';
      _selectedTimezone = prefs.getString('timezone') ?? 'UTC-11:00';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedCountry != null) {
      await prefs.setString('countryCode', _selectedCountry!.countryCode);
    }
    await prefs.setString('platform', _selectedPlatform);
    await prefs.setString('timezone', _selectedTimezone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A4F46), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
                children: [
                  _buildSettingsCard(
                    title: 'التخصيص',
                    children: [
                      _buildCountrySelector(),
                      const SizedBox(height: 16),
                      _buildDropdownItem(
                        icon: Icons.computer,
                        label: 'المنصة',
                        value: _selectedPlatform,
                        items: ['Quotex', 'Binance', 'Bybit'],
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedPlatform = newValue;
                            });
                            _saveSettings();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownItem(
                        icon: Icons.watch_later_outlined,
                        label: 'التوقيت',
                        value: _selectedTimezone,
                        items: ['UTC-11:00', 'UTC+2:00', 'UTC+5:30'],
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedTimezone = newValue;
                            });
                            _saveSettings();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsCard(
                    title: 'الحساب',
                    children: [
                      _buildListItem(
                        icon: Icons.lock_outline,
                        text: 'تغيير كلمة المرور',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required List<Widget> children}) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Divider(height: 24, color: Colors.white24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySelector() {
    return InkWell(
      onTap: () {
        showCountryPicker(
          context: context,
          onSelect: (Country country) {
            setState(() {
              _selectedCountry = country;
            });
            _saveSettings();
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
            Text(
              '${_selectedCountry?.flagEmoji ?? ''} ${_selectedCountry?.name ?? ''}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
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
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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