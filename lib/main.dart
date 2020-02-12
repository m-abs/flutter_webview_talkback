import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Webview talkback test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final initialUrl =
      'https://readium2.herokuapp.com/pub/L2FwcC9taXNjL2VwdWJzL2NoaWxkcmVucy1saXRlcmF0dXJlLmVwdWI=/EPUB/s04.xhtml';

  Completer<WebViewController> _webViewController =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Semantics(
        enabled: true,
        child: WebView(
          debuggingEnabled: true,
          initialUrl: initialUrl,
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: [
            JavascriptChannel(
                name: 'Flutter',
                onMessageReceived: (jsMessage) {
                  String message = jsMessage.message;

                  try {
                    dynamic data = json.decode(message);
                    print(data);
                  } catch (err) {
                    print(err);
                  }
                }),
          ].toSet(),
          onWebViewCreated: (WebViewController webViewController) async {
            _webViewController.complete(webViewController);

            if (await webViewController.currentUrl() != initialUrl) {
              webViewController.loadUrl(initialUrl);
            }
          },
          navigationDelegate: (NavigationRequest request) {
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
        ),
      ),
    );
  }
}
