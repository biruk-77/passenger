import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // --- WebView Logic is now inside this screen ---
  final String _url = 'https://bankeru.com/help.html';
  InAppWebViewController? _controller;
  int _progress = 0;
  // --- End of WebView Logic ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        // --- AppBar additions from the old WebViewScreen ---
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller?.reload(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _progress > 0 && _progress < 100
              ? LinearProgressIndicator(value: _progress / 100)
              : const SizedBox.shrink(),
        ),
      ),
      body: SafeArea(
        // --- The body is now the InAppWebView widget directly ---
        child: InAppWebView(
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            transparentBackground: true,
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
          ),
          initialUrlRequest: URLRequest(url: WebUri(_url)),
          onWebViewCreated: (controller) => _controller = controller,
          onProgressChanged: (controller, progress) {
            setState(() => _progress = progress);
          },
          onReceivedError: (controller, request, error) {
            debugPrint("WebView error: ${error.description}");
          },
        ),
      ),
    );
  }
}