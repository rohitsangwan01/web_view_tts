import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../helper/logger.dart';
import '../services/tts_service.dart';

void registerTTSHandler(InAppWebViewController controller) {
  ///  Speak
  controller.addJavaScriptHandler(
      handlerName: 'speak',
      callback: (dynamic args) async {
        //logSuccess(args.toString());
        String? text;
        String? lang;
        double? volume;
        double? rate;
        double? pitch;
        try {
          var data = args[0]['data'];
          text = data['text'];
          if (args.toString().contains('lang')) {
            String language = data['lang'].toString();
            if (language != "default") lang = language;
          }
          if (args.toString().contains('volume')) {
            volume = double.tryParse(data['volume'].toString());
          }
          if (args.toString().contains('rate')) {
            rate = double.tryParse(data['rate'].toString());
          }
          if (args.toString().contains('pitch')) {
            pitch = double.tryParse(data['pitch'].toString());
          }
        } catch (e) {
          logError(e.toString());
        }
        return await TtsService.to.speak(
          text,
          lang: lang,
          volume: volume,
          rate: rate,
          pitch: pitch,
        );
      });

  /// cancel
  controller.addJavaScriptHandler(
      handlerName: 'cancel',
      callback: (dynamic args) async {
        return await TtsService.to.cancel();
      });

  /// pause
  controller.addJavaScriptHandler(
      handlerName: 'pause',
      callback: (dynamic args) async {
        return await TtsService.to.pause();
      });

  /// resume
  controller.addJavaScriptHandler(
      handlerName: 'resume',
      callback: (dynamic args) async {
        return await TtsService.to.resume();
      });

  ///To GetVoices
  controller.addJavaScriptHandler(
      handlerName: 'getVoices',
      callback: (dynamic args) async {
        return await TtsService.to.getVoices();
      });
}
