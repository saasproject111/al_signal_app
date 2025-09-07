import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UsdtPaymentPage extends StatefulWidget {
  final String invoiceUrl;

  const UsdtPaymentPage({super.key, required this.invoiceUrl});

  @override
  State<UsdtPaymentPage> createState() => _UsdtPaymentPageState();
}

class _UsdtPaymentPageState extends State<UsdtPaymentPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.invoiceUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("الدفع بالـ USDT"),
      ),
      body: WebViewWidget(controller: _controller), // ✅ الإصدار الجديد
    );
  }
}
