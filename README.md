# WebView TTS

[![web_view_tts version](https://img.shields.io/pub/v/web_view_tts?label=web_view_tts)](https://pub.dev/packages/web_view_tts)

Flutter library To add Text-To-Speech Support in Android WebView

## Getting Started

Using [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) for WebView
and [flutter_tts](https://pub.dev/packages/flutter_tts) for Android TTS

Import these Libraries in your pubspec.yaml

```dart
flutter_inappwebview: ^5.4.3+7
web_view_tts: 0.0.1
```

Add WebView in your Project , Check flutter_inappwebview [docs](https://inappwebview.dev/docs/) for setting up WebView

And check [flutter_tts](https://pub.dev/packages/flutter_tts) docs for adding TTS

## Usage

in your `onLoadStart` callback of flutter_inappwebview , add this method

```dart
onLoadStart(controller) async {
    await WebViewTTS.init(controller: controller);
}
```

Checkout [/example](https://github.com/rohitsangwan01/web_view_tts/blob/main/example/lib/main.dart) app for more details

## Features

The web_view_tts lib supports the following TTS Api's:

- Speak
- Stop
- Pause
- Resume
- getVoices
- setVolume
- setPitch
- setRate

## Note

This library will add TTS polyfill for android only , because IOS WebView already supports this

## Additional information

This is Just The Initial Version feel free to Contribute or Report any Bug!
