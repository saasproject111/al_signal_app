import 'dart:convert';
import 'package:http/http.dart' as http;

class CryptoService {
  final String _baseUrl = 'https://api.coingecko.com/api/v3/simple/price';

  // دالة لجلب أسعار العملات الثلاث الرئيسية
  Future<Map<String, dynamic>> getPrices() async {
    try {
      final response = await http.get(
        // نطلب أسعار البيتكوين، الإيثيريوم، والتيثر مقابل الدولار
        Uri.parse('$_baseUrl?ids=bitcoin,ethereum,tether&vs_currencies=usd'),
      );

      if (response.statusCode == 200) {
        // إذا نجح الطلب، قم بإرجاع البيانات
        return json.decode(response.body);
      } else {
        // إذا فشل الطلب، أرجع خريطة فارغة
        print('Failed to load prices: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      // إذا حدث خطأ في الاتصال، أرجع خريطة فارغة
      print('Error fetching prices: $e');
      return {};
    }
  }
}
