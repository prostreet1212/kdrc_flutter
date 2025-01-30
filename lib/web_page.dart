import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:ui';



class WebPage extends StatefulWidget {
  WebPage({Key? key}) : super(key: key);

  @override
  State<WebPage> createState() => _NestedWebviewDemoState();
}

class _NestedWebviewDemoState extends State<WebPage> {


  final ScrollController scrollController = ScrollController();
  late WebViewController webViewController;
  ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1);
  ValueNotifier<int> progressNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(

          onPageStarted: (url) {
          },
          onPageFinished: (a) {
            print('Позиция ${scrollController.position}');
            webViewController.runJavaScript(scrollHeightJs);

          },
          onWebResourceError: (e) {
            //webViewStatusNotifier.value = WebViewStatus.failed;
            print('ERROR: ${e.errorCode}');
          },
          onProgress: (progress) {
            progressNotifier.value = progress;
          }
      ))..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('ScrollHeightNotifier',
          onMessageReceived: (message){
            final String msg = message.message;
            final double? height = double.tryParse(msg);
            if (height != null) {
              scrollHeightNotifier.value = height;
            }
          })
      ..loadRequest(Uri.parse('https://flutter.dev'));
  }
  @override
  Widget build(BuildContext context) {

    return  WillPopScope(
      onWillPop: ()async{
        if(await webViewController.canGoBack()){
          webViewController.goBack();
        }
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('NestedWebview'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    scrollController.animateTo(
                      144,
                      duration: const Duration(seconds: 1),
                      curve: Curves.linear,
                    );
                  },
                  child: const Text(
                    'animate to Webview bottom',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ))
            ],
          ),
          body: Stack(
            children: <Widget>[
              CustomScrollView(
                //physics: NeverScrollableScrollPhysics(),
                controller: scrollController,
                slivers: <Widget>[
                  // SliverToBoxAdapter(
                  //   child: Container(
                  //     height: 100,
                  //     color: Colors.red,
                  //     child: const Center(
                  //       child: Text(
                  //         'Header',
                  //         style: TextStyle(color: Colors.white),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SliverAppBar(
                      title: Text('aaa'),
                      expandedHeight: 200,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        background: Image.network(
                          'https://placehold.co/600x200?text=KDRC+Header',
                          fit: BoxFit.cover,
                        ),)),
                  ValueListenableBuilder<double>(

                    valueListenable:
                    scrollHeightNotifier,
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
                          webViewController
                              .scrollTo(0, y.ceil());
                        },
                        child: child,
                      );
                    },
                    child: WebViewWidget(controller: webViewController),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: 300,
                      color: Colors.green,
                      child: const Center(
                        child: Text(
                          'Footer',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ],
          )
      ),
    )

    ;
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




