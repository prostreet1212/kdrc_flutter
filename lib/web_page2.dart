import 'dart:ffi';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:ui';

class WebPage2 extends StatefulWidget {
  WebPage2({Key? key}) : super(key: key);

  @override
  State<WebPage2> createState() => _NestedWebviewDemoState();
}

class _NestedWebviewDemoState extends State<WebPage2> {
  final ScrollController scrollController = ScrollController();
  late WebViewController webViewController;
  ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(700);

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (url) {
            scrollController.jumpTo(0);
            scrollHeightNotifier.value = 700;
            print('новый скрол: ${scrollController.offset}');
          },
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
      ..addJavaScriptChannel('ScrollHeightNotifier',
          onMessageReceived: (message) {
            final String msg = message.message;
            final double? height = double.tryParse(msg);
            if (height != null) {
              scrollHeightNotifier.value = height;
            }
          })
      ..loadRequest(Uri.parse('https://kdrc.ru'));

    scrollController.addListener((){
print(scrollController.offset);
    });
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

        body: Stack(
          children: <Widget>[
            CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
              /* SliverAppBar(
                  title: Text('aaa'),
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Image.asset(
                      'assets/images/titleimage.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),*/
                ExtendedSliverAppbar(
                  title: const Text(
                    'ExtendedSliverAppbar',
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: const BackButton(
                    onPressed: null,
                    color: Colors.white,
                  ),
                  background: Image.asset(
                    'assets/cypridina.jpeg',
                    fit: BoxFit.cover,
                  ),
                  actions: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                    ),
                  ),
                ),
                SliverPinnedPersistentHeader(
                  delegate: MySliverPinnedPersistentHeaderDelegate(
                    minExtentProtoType: Container(
                      height: 120.0,
                      color: Colors.red.withOpacity(0.5),
                      child: TextButton(
                        child: const Text('minProtoType'),
                        onPressed: () {
                          print('minProtoType');
                        },
                      ),
                      alignment: Alignment.topCenter,
                    ),
                    maxExtentProtoType: Container(
                      height: 200.0,
                      color: Colors.blue,
                      child: TextButton(
                        child: const Text('maxProtoType'),
                        onPressed: () {
                          print('maxProtoType');
                        },
                      ),
                      alignment: Alignment.bottomCenter,
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
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.grey[50],
            shape: const CircleBorder(),
            child: Icon(
              Icons.call,
              color: Color.fromARGB(255, 247, 176, 116),
              size: 36,
            ),
            onPressed: (){
              scrollController.animateTo(
                144,
                duration: const Duration(seconds: 1),
                curve: Curves.linear,
              );
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


class MySliverPinnedPersistentHeaderDelegate
    extends SliverPinnedPersistentHeaderDelegate {
  MySliverPinnedPersistentHeaderDelegate({
    required Widget minExtentProtoType,
    required Widget maxExtentProtoType,
  }) : super(
    minExtentProtoType: minExtentProtoType,
    maxExtentProtoType: maxExtentProtoType,
  );
  @override
  Widget build(BuildContext context, double shrinkOffset, double? minExtent,
      double maxExtent, bool overlapsContent) {
    print(shrinkOffset);
    return Stack(
      children: <Widget>[
        Positioned(
          child: maxExtentProtoType,
          top: -shrinkOffset,
          bottom: 0,
          left: 0,
          right: 0,
        ),
        Positioned(
          child: minExtentProtoType,
          top: 0,
          left: 0,
          right: 0,
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(SliverPinnedPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}