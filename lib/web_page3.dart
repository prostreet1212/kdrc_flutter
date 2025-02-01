import 'dart:ffi';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:ui';

class WebPage3 extends StatefulWidget {
  WebPage3({Key? key}) : super(key: key);

  @override
  State<WebPage3> createState() => _NestedWebviewDemoState();
}

class _NestedWebviewDemoState extends State<WebPage3> {
  //final ScrollController scrollController = ScrollController();
  //ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1);
  late WebViewController webViewController;
  double _appBarHeight = 217;
  double _maxAppBarHeight = 217;
  double _minAppBarHeight = kToolbarHeight;
  double _scrollOffset = 0.0;

  void _onScroll(double scrollOffset) {
    setState(() {
      _scrollOffset = scrollOffset;

      // Плавное изменение высоты AppBar на основе прокрутки
      _appBarHeight = _maxAppBarHeight - _scrollOffset;

      // Ограничиваем высоту AppBar в пределах [_minAppBarHeight, _maxAppBarHeight]
      if (_appBarHeight < _minAppBarHeight) {
        _appBarHeight = _minAppBarHeight;
      } else if (_appBarHeight > _maxAppBarHeight) {
        _appBarHeight = _maxAppBarHeight;
      }
    });

  }




  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (u) {
        webViewController.runJavaScript(
          """
                  window.addEventListener('scroll', function() {
                    var scrollOffset = window.pageYOffset;
                    ScrollChannel.postMessage(scrollOffset.toString());
                  });
                  """,
        );
      }))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://kdrc.ru'))
      ..addJavaScriptChannel(
        'ScrollChannel',
        onMessageReceived: (message) {
          // Получаем данные о прокрутке и обновляем AppBar
          double scrollOffset = double.tryParse(message.message) ?? 0;
          print('скрол у: ${scrollOffset.toString()}');
          _onScroll(scrollOffset);
        },
      );

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
      child: SafeArea(
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
         SliverAppBar(
           pinned: true,
         ),

          SliverToNestedScrollBoxAdapter(
          childExtent: 1000,
          onScrollOffsetChanged: (double scrollOffset) {
            double y = scrollOffset;
            if (Platform.isAndroid) {
              // https://github.com/flutter/flutter/issues/75841
              y *= window.devicePixelRatio;
            }
            webViewController.scrollTo(0, y.ceil());
          },
          child: WebViewWidget(controller: webViewController),
        )

            ],
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
               /* scrollController.animateTo(
                  144,
                  duration: const Duration(seconds: 1),
                  curve: Curves.linear,
                );*/
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
