import 'package:flutter/foundation.dart';
import '../models/subscription_plan.dart';

class SubscriptionService extends ChangeNotifier {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  SubscriptionPlan? _currentPlan;
  bool _isYearlyBilling = false;

  SubscriptionPlan? get currentPlan => _currentPlan;
  bool get isYearlyBilling => _isYearlyBilling;

  void setCurrentPlan(SubscriptionPlan plan) {
    _currentPlan = plan;
    notifyListeners();
  }

  void setBillingPeriod(bool isYearly) {
    _isYearlyBilling = isYearly;
    notifyListeners();
  }

  double getCurrentPrice() {
    if (_currentPlan == null || _currentPlan!.isFree) return 0.0;
    
    final priceString = _isYearlyBilling 
        ? _currentPlan!.yearlyPrice 
        : _currentPlan!.monthlyPrice;
    
    return double.tryParse(priceString.replaceAll('\$', '')) ?? 0.0;
  }

  List<String> getCurrentFeatures() {
    return _currentPlan?.features ?? [];
  }

  bool hasFeature(String feature) {
    return getCurrentFeatures().contains(feature);
  }

  void cancelSubscription() {
    _currentPlan = SubscriptionPlan.getPlans().first; // العودة للخطة المجانية
    notifyListeners();
  }
}
