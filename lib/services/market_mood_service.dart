import 'dart:convert';
import 'package:http/http.dart' as http;

// كلاس بسيط لتخزين بيانات المؤشر
class MarketMood {
  final int value; // القيمة من 0 إلى 100
  final String classification; // الوصف (Extreme Fear, Greed, etc.)

  MarketMood({required this.value, required this.classification});
}

class MarketMoodService {
  // الرابط الخاص بالـ API المجاني
  final String _apiUrl = 'https://api.alternative.me/fng/';

  Future<MarketMood?> getFearAndGreedIndex() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // استخلاص البيانات من الرد
        final moodData = data['data'][0];
        return MarketMood(
          value: int.parse(moodData['value']),
          classification: moodData['value_classification'],
        );
      } else {
        // حدث خطأ في الخادم
        print('Failed to load F&G Index');
        return null;
      }
    } catch (e) {
      // حدث خطأ في الاتصال
      print('Error fetching F&G Index: $e');
      return null;
    }
  }
}
