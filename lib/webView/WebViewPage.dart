import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatelessWidget {
  final String url;

  WebViewPage({ required String initialUrl, required JavaScriptMode javascriptMode, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView'),
      ),
      body: WebViewPage(
        javascriptMode: JavaScriptMode.unrestricted, url: url, initialUrl: url,
      ),
    );
  }
}
