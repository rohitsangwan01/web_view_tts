import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:web_view_tts/web_view_tts.dart';

import 'dart_to_js.dart';

class TtsService {
  static TtsService? _instance;
  TtsService._();
  static TtsService get to => _instance ??= TtsService._();

  FlutterTts? _flutterTts;

  Future<void> init() async {
    _flutterTts = FlutterTts();
    await setEventListeners();
    await updateVoices();
  }

  String _remainingTextToSpeak = "";

  Future speak(
    String? text, {
    String? lang,
    double? volume,
    double? pitch,
    double? rate,
  }) async {
    try {
      if (volume != null) _flutterTts?.setVolume(volume);
      if (pitch != null) _flutterTts?.setPitch(pitch);
      if (rate != null) _flutterTts?.setSpeechRate(rate);
      if (lang != null) _flutterTts?.setLanguage(lang);
      if (text != null) {
        return await _flutterTts?.speak(text);
      }
    } catch (e) {
      logError(e.toString());
    }
  }

  Future pause() async {
    try {
      await _flutterTts?.stop();
      DartToJs.to.speakEvent("pause");
    } catch (e) {
      logError(e.toString());
    }
  }

  Future cancel() async {
    try {
      DartToJs.to.speakEvent("complete");
    } catch (e) {
      logError(e.toString());
    }
  }

  Future resume() async {
    try {
      if (_remainingTextToSpeak == "") {
        DartToJs.to.speakEvent("complete");
      } else {
        _flutterTts?.speak(_remainingTextToSpeak);
      }
    } catch (e) {
      logError(e.toString());
    }
  }

  Future setEventListeners() async {
    _flutterTts?.setStartHandler(() => DartToJs.to.speakEvent("start"));
    _flutterTts?.setCompletionHandler(() => DartToJs.to.speakEvent("complete"));
    _flutterTts?.setContinueHandler(() => DartToJs.to.speakEvent("continue"));
    _flutterTts?.setPauseHandler(() => DartToJs.to.speakEvent("pause"));
    _flutterTts?.setProgressHandler((text, start, end, word) {
      _remainingTextToSpeak = text.replaceRange(0, start, "").trim();
    });
    _flutterTts?.setErrorHandler((dynamic message) {
      DartToJs.to.speakEvent(
        "error",
        data: message?.toString() ?? "Something went wrong",
      );
    });
  }

  Future getVoices() async {
    //returns list of Map -> [{name: ur-PK-language, locale: ur-PK}]
    var voices = await _flutterTts?.getVoices;
    var result = [];
    if (voices != null && voices.length != 0) {
      for (var voice in voices) {
        var voiceMap = {
          "name": "${voice["name"]}",
          "locale": "${voice["locale"]}"
        };
        result.add(json.encode(voiceMap));
      }
    }
    return jsonEncode(result);
  }

  Future updateVoices() async {
    try {
      var voices = await getVoices();
      await DartToJs.to.updateLanguages(voices);
    } catch (e) {
      logError(e.toString());
    }
  }
}
