import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebViewPage({
    super.key,
    required this.paymentUrl,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            debugPrint("✅ Page loaded: $url");

            // هنا تقدر تتحقق لو الدفع تم بنجاح
            if (url.contains("success")) {
              Navigator.of(context).pop(true); // يرجع نجاح
            }
            if (url.contains("cancel")) {
              Navigator.of(context).pop(false); // يرجع فشل أو إلغاء
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إتمام الدفع"),
        backgroundColor: Colors.black87,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
