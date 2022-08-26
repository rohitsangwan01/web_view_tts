import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_view_tts/src/services/dart_to_js.dart';
import 'package:web_view_tts/src/services/tts_service.dart';
import 'js_handler/js_handler.dart';

class WebViewTTS {
  static bool _isInitialized = false;

  ///call `init` in `OnLoad Callback` of WebView
  static init({
    required InAppWebViewController controller,
  }) async {
    // add only for Android WebView
    if (kIsWeb || !Platform.isAndroid) return;
    await _addJsHandlers(controller);
    await _insertTTSJs(controller);
    await _initDartToJs(controller);
    await _initializeTTSService();
  }

  // Initialize TtsService only Once
  static _initializeTTSService() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await TtsService.to.init();
  }

  ///`Add All Handlers for JS Communication`
  static Future<void> _addJsHandlers(InAppWebViewController controller) =>
      JsHandler(webViewController: controller).addHandlers();

  ///`Insert JS Files`
  static Future<void> _insertTTSJs(InAppWebViewController controller) async {
    for (var jsFile in _jsFiles) {
      await controller.injectJavascriptFileFromAsset(
          assetFilePath: "packages/web_view_tts/assets/$jsFile.js");
    }
  }

  ///`Insert Dart To JS Handlers`
  static _initDartToJs(InAppWebViewController controller) {
    DartToJs.to.controller = controller;
  }

  ///`All Javascript Files`
  static final _jsFiles = ["android_tts"];
}
