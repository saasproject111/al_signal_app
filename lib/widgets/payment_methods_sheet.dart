import 'dart:ui';
import 'package:flutter/material.dart';

// تم تحويلها إلى StatelessWidget لضمان البساطة والأداء
class PaymentMethodsSheet extends StatelessWidget {
  const PaymentMethodsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0A4F46).withOpacity(0.9), Colors.black.withOpacity(0.9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'إتمام الدفع بأمان',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildPaymentOption(
                  logoAsset: 'assets/visa_mastercard.png',
                  name: 'Visa / Mastercard',
                  onTap: () {},
                ),
                const Divider(color: Colors.white24),
                _buildPaymentOption(
                  logoAsset: 'assets/usdt.png',
                  name: 'USDT',
                  onTap: () {},
                ),
                const Divider(color: Colors.white24),
                _buildPaymentOption(
                  logoAsset: 'assets/skrill.png',
                  name: 'Skrill',
                  onTap: () {},
                ),
                const Divider(color: Colors.white24),
                _buildPaymentOption(
                  logoAsset: 'assets/redotpay.png',
                  name: 'RedotPay',
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                _buildTrustBadges(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String logoAsset,
    required String name,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              leading: Image.asset(logoAsset, height: 40, width: 60, errorBuilder: (c, e, s) => const Icon(Icons.payment, color: Colors.white)),
              title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, color: Colors.greenAccent[400], size: 20),
        const SizedBox(width: 8),
        const Text(
          'SSL Secure Payment',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(width: 20),
        Image.asset('assets/visa_mastercard.png', height: 25, errorBuilder: (c, e, s) => const SizedBox(width: 40)),
      ],
    );
  }
}

