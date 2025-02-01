import 'dart:ffi';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:ui';

class WebPageTest extends StatefulWidget {
  WebPageTest({Key? key}) : super(key: key);

  @override
  State<WebPageTest> createState() => _NestedWebviewDemoState();
}

class _NestedWebviewDemoState extends State<WebPageTest> {
  final ScrollController scrollController = ScrollController();
  late WebViewController webViewController;
  ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1);

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (url) {},
          onPageFinished: (a) {
            print('Позиция ${scrollController.position}');
            webViewController.runJavaScript(scrollHeightJs);

          },
          onWebResourceError: (e) {
            //webViewStatusNotifier.value = WebViewStatus.failed;
            print('ERROR: ${e.errorCode}');
          },
          onProgress: (progress) {}))

      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ScrollChannel',
        onMessageReceived: (message) {
          // Получаем данные о прокрутке и обновляем AppBar
          double scrollOffset = double.tryParse(message.message) ?? 0;
          print('скрол у: ${scrollOffset.toString()}');
          //_onScroll(scrollOffset);
        },
      )
      ..addJavaScriptChannel('ScrollHeightNotifier',
          onMessageReceived: (message) {
        final String msg = message.message;
        final double? height = double.tryParse(msg);
        if (height != null) {
          scrollHeightNotifier.value = height;
        }
      })
      ..loadRequest(Uri.parse('https://kdrc.ru'));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController.canGoBack()) {
          webViewController.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('NestedWebview'),
        //   actions: <Widget>[
        //     TextButton(
        //         onPressed: () {
        //           scrollController.animateTo(
        //             144,
        //             duration: const Duration(seconds: 1),
        //             curve: Curves.linear,
        //           );
        //         },
        //         child: const Text(
        //           'animate to Webview bottom',
        //           style: TextStyle(
        //             color: Colors.white,
        //           ),
        //         ))
        //   ],
        // ),

        body: SafeArea(
          child: Stack(
            children: <Widget>[
              CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  SliverAppBar(
                    title: Text('aaa'),
                    expandedHeight: 200,
                    collapsedHeight: 56,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Image.asset(
                        'assets/images/titleimage.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: scrollHeightNotifier,
                    builder: (
                      BuildContext context,
                      double scrollHeight,
                      Widget? child,
                    ) {
                      return SliverToNestedScrollBoxAdapter(
                        childExtent: scrollHeight,
                        onScrollOffsetChanged: (double scrollOffset) {
                          double y = scrollOffset;
                          if (Platform.isAndroid) {
                            // https://github.com/flutter/flutter/issues/75841
                            y *= window.devicePixelRatio;
                          }
                          webViewController.scrollTo(0, y.ceil());
                        },
                        child: child,
                      );
                    },
                    child: WebViewWidget(controller: webViewController),
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.grey[50],
            shape: const CircleBorder(),
            child: Icon(
              Icons.call,
              color: Color.fromARGB(255, 247, 176, 116),
              size: 36,
            ),
            onPressed: () {
              scrollController.animateTo(
                              144,
                              duration: const Duration(seconds: 1),
                              curve: Curves.linear,
                            );
             /* showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(),
                      title: Text(
                        'Приемная',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      content: Text('Позвонить в приёмную?'),
                      actions: [
                        TextButton(
                          child: Text('Да'),
                          onPressed: () async{
                            final Uri _url = Uri.parse('https://flutter.dev');
                            await launchUrl(_url);
                          },
                        ),
                        TextButton(
                          child: Text('Нет'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  });*/
            }),
      ),
    );
  }
}

const String scrollHeightJs = '''(function() {
  var height = 0;
  var notifier = window.ScrollHeightNotifier || window.webkit.messageHandlers.ScrollHeightNotifier;
  if (!notifier) return;

  function checkAndNotify() {
    var curr = document.body.scrollHeight;
    if (curr !== height) {
      height = curr;
      notifier.postMessage(height.toString());
    }
  }

  var timer;
  var ob;
  if (window.ResizeObserver) {
    ob = new ResizeObserver(checkAndNotify);
    ob.observe(document.body);
  } else {
    timer = setTimeout(checkAndNotify, 200);
  }
  window.onbeforeunload = function() {
    ob && ob.disconnect();
    timer && clearTimeout(timer);
  };
})();''';
