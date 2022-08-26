import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_view_tts/web_view_tts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flowser",
      home: WebsiteView(),
    ),
  );
}

class WebsiteView extends StatefulWidget {
  const WebsiteView({Key? key}) : super(key: key);
  @override
  State<WebsiteView> createState() => _WebsiteViewState();
}

class _WebsiteViewState extends State<WebsiteView> {
  var url = "https://dlutton.github.io/flutter_tts/#/";

  final urlController = TextEditingController();
  InAppWebViewController? webViewController;
  bool canGoBack = false;
  double? progress;
  int currentKey = 1;

  onLoadStart(controller) async {
    await WebViewTTS.init(controller: controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Flowser"),
          centerTitle: true,
          leading: canGoBack
              ? IconButton(
                  onPressed: () {
                    webViewController?.goBack();
                  },
                  icon: const Icon(Icons.arrow_back_ios))
              : const SizedBox(),
          actions: [
            IconButton(
                onPressed: () async {
                  setState(() {
                    currentKey++;
                  });
                },
                icon: const Icon(Icons.sync))
          ],
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
          progress == null
              ? const SizedBox()
              : LinearProgressIndicator(
                  color: Colors.green,
                  value: progress,
                ),
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
            controller: urlController,
            keyboardType: TextInputType.url,
            onSubmitted: (value) {
              var url = Uri.parse(value);
              if (url.scheme.isEmpty) {
                url = Uri.parse("https://www.google.com/search?q=$value");
              }
              webViewController?.loadUrl(urlRequest: URLRequest(url: url));
            },
          ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: Key('$currentKey'),
                  initialUrlRequest: URLRequest(url: Uri.parse(url)),
                  onLoadStart: (cntrl, url) => onLoadStart(cntrl),
                  initialOptions: InAppWebViewGroupOptions(
                      android: AndroidInAppWebViewOptions(
                    useHybridComposition: true,
                  )),
                  pullToRefreshController: PullToRefreshController(
                    onRefresh: () async {
                      await webViewController?.reload();
                    },
                  ),
                  onLoadStop: (controller, uri) async {
                    bool canGoBack = await controller.canGoBack();
                    setState(() {
                      urlController.text = uri.toString();
                      canGoBack = canGoBack;
                    });
                  },
                  onProgressChanged: ((controller, prg) {
                    setState(() {
                      progress = prg / 100;
                      if (prg == 100) {
                        progress = null;
                      }
                    });
                  }),
                  onConsoleMessage: (controller, consoleMessage) {
                    logSuccess(
                        "ConsoleMessage : ${consoleMessage.messageLevel.toString()} :  ${consoleMessage.message} ");
                  },
                ),
              ],
            ),
          ),
        ])));
  }
}
