import 'dart:convert';
import 'package:http/http.dart' as http;

class CryptoService {
  final String _baseUrl = 'https://api.coingecko.com/api/v3';

  /// جلب أسعار العملات الرئيسية (BTC, ETH, USDT)
  Future<Map<String, dynamic>> getPrices() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/simple/price?ids=bitcoin,ethereum,tether&vs_currencies=usd',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load prices: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching prices: $e');
      return {};
    }
  }

  /// جلب بيانات السوق العالمي (القيمة السوقية، حجم التداول، هيمنة BTC)
  Future<Map<String, dynamic>> getGlobalMarketData() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/global'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load global data: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching global data: $e');
      return {};
    }
  }

  /// جلب أسعار OTC من Binance P2P (USDT مقابل USD كمثال)
  Future<List<dynamic>> getOtcPrices() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://p2p.binance.com/bapi/c2c/v2/friendly/c2c/adv/search'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "asset": "USDT",
          "fiat": "USD",
          "tradeType": "BUY",
          "rows": 5,
          "page": 1
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        print('Failed to load OTC data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching OTC prices: $e');
      return [];
    }
  }
}
