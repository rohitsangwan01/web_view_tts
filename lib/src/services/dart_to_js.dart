import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../helper/logger.dart';

/// `JsEvents` contains all Events for Communications
class JsEvents {
  static String speakEvents = 'flutterSpeakEventListener';
  static String languageEvents = 'flutterLanguageEventListener';
}

///`To Call Javascript event From Dart`
class DartToJs {
  static DartToJs? _instance;
  DartToJs._();
  static DartToJs get to => _instance ??= DartToJs._();

  /// Initialize DartToJs Controller
  late InAppWebViewController controller;

  //To Send Speak Events
  Future<void> speakEvent(String eventType, {String? data}) async {
    await dispatchJsEvent(
      event: JsEvents.speakEvents,
      data: {"type": eventType, "data": data ?? ""},
    );
  }

  //To updates Languages
  Future<void> updateLanguages(String data) async {
    await dispatchJsEvent(
        event: JsEvents.languageEvents, data: {"languages": data});
  }

  // To Update connection Method in JavaScript
  Future<void> dispatchJsEvent({
    required String event,
    required data,
  }) async {
    try {
      String jsonData = jsonEncode(data);
      var response = await controller.callAsyncJavaScript(
        functionBody: """
            const event = new CustomEvent("$event", {
              detail: $jsonData
            });
            window.dispatchEvent(event);
          """,
      );
      if (response?.error != null) {
        logError(response?.error ?? "");
      }
    } catch (e) {
      logError(e.toString());
    }
  }
}
