// Replace the content of lib/final/view/web_view.dart with this code

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebViewController extends GetxController {
  WebViewController? controller;
  RxBool isLoading = true.obs;
  RxString currentUrl = ''.obs;

  void initializeController(String url) {
    if (controller == null) {
      currentUrl.value = url;
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              isLoading.value = true;
            },
            onPageFinished: (String url) {
              isLoading.value = false;
            },
            onWebResourceError: (WebResourceError error) {
              isLoading.value = false;
            },
          ),
        )
        ..loadRequest(Uri.parse(url));
    } else if (url != currentUrl.value) {
      currentUrl.value = url;
      controller!.loadRequest(Uri.parse(url));
    }
  }

  void reload() {
    if (controller != null) {
      isLoading.value = true;
      controller!.reload();
    }
  }

  @override
  void onClose() {
    // This controller is permanent, but we'll include this for completeness
    controller = null;
    super.onClose();
  }
}
class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({
    super.key,
    required this.url,
  });

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> with AutomaticKeepAliveClientMixin {
  late final CustomWebViewController _webViewCtrl;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _webViewCtrl = Get.find<CustomWebViewController>();
    _webViewCtrl.initializeController(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        // Prevent WebView from being destroyed on back press
        Get.offNamed('/dashboard');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          title: const Text(
            'Odoo Portal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _webViewCtrl.reload(),
            ),
          ],
        ),
        body: Obx(
              () => Stack(
            children: [
              // The WebView
              _webViewCtrl.controller != null
                  ? WebViewWidget(controller: _webViewCtrl.controller!)
                  : const Center(child: Text("Initializing WebView...")),

              // Loading indicator
              if (_webViewCtrl.isLoading.value)
                Container(
                  color: isDark ? Colors.black54 : Colors.white70,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Loading Odoo Portal...",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}