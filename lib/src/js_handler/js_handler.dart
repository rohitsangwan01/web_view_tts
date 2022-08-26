import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'tts_handler.dart';

class JsHandler {
  InAppWebViewController webViewController;
  JsHandler({required this.webViewController});

  // register a JavaScript handler
  Future<void> addHandlers() async {
    registerTTSHandler(webViewController);
  }
}
