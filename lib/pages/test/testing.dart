import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kdrc_flutter/cubits/scroll_height_cubit.dart';

import '../../locator_service.dart';
import '../../utils/utils.dart';

enum ScrollStatus { prev, forward }

class Testing extends StatefulWidget {
  const Testing({super.key});

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1);

  // ScrollController nestedController = ScrollController();
  //late WebViewController webViewController;
  final GlobalKey<NestedScrollViewState> myKey = GlobalKey();
  ScrollStatus scrollStatus = ScrollStatus.forward;
  double oldScroll = 0.0;

  //double prevPixel=0;
  List<double> prevPixels = [];
  String prevUrl = '';

  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    /*  webViewController = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            await webViewController.runJavaScript(Utils.scrollHeightJs);
          },
        ),
      )
      ..addJavaScriptChannel('ScrollHeightNotifier',
          onMessageReceived: (message) {
        final String msg = message.message;
        final double? height = double.tryParse(msg);
        if (height != null) {
          scrollHeightNotifier.value = height;
        }
        //scrollController.jumpTo(0);
      })
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        //Uri.parse('https://kdrc.ru/novosti'),
        Uri.parse('https://kdrc.ru'),
      );*/
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) => sl<ScrollHeightCubit>(),
      child: WillPopScope(
        onWillPop: () async {
          if (await _webViewController.canGoBack()) {
            scrollStatus = ScrollStatus.prev;
            _webViewController.goBack();
          }
          return false;
        },
        child: SafeArea(
          child: Scaffold(
            body: NestedScrollView(
              key: myKey,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                    handle: SliverOverlapAbsorberHandle(),
                    sliver: SliverSafeArea(
                        sliver: SliverAppBar(
                      expandedHeight: 256,
                      collapsedHeight: 56,
                      pinned: true,
                    )),
                  )
                ];
              },
              body: CustomScrollView(
                physics: ClampingScrollPhysics(),
                slivers: [
                  BlocBuilder<ScrollHeightCubit, double>(builder: (c, state) {
                    return SliverToNestedScrollBoxAdapter(
                      childExtent: state,
                      onScrollOffsetChanged: (scrollOffset) {
                        double y = scrollOffset;
                        if (Platform.isAndroid) {
                          y *= View.of(context).devicePixelRatio;
                        }
                        _webViewController.scrollTo(x: 0, y: y.ceil());
                      },
                      child: InAppWebView(
                        initialUrlRequest: URLRequest(
                          url: WebUri('https://kdrc.ru'),
                        ),
                        onWebViewCreated: (controller) {
                          _webViewController = controller;
                          controller.addJavaScriptHandler(
                              handlerName: 'ScrollHeightNotifier',
                              callback: (args) {
                                print('aaaaaaaa: ${args[0]}');
                                double height=(args[0] as int).toDouble();
                                sl<ScrollHeightCubit>().updateScrollHeight(height);
                              });
                        },
                        onLoadStop: (controller, url) async {
                          print('STOP');
                          controller.evaluateJavascript(
                              source:  '''
(function() {
  var height = 0;
  
  function checkAndNotify() {
    var curr = document.body.scrollHeight;
    if (curr !== height) {
      height = curr;
      // Используем window.flutter_inappwebview.callHandler для InAppWebView
      window.flutter_inappwebview.callHandler('ScrollHeightNotifier', height);
    }
  }

  var timer;
  var ob;
  if (window.ResizeObserver) {
    ob = new ResizeObserver(checkAndNotify);
    ob.observe(document.body);
  } else {
    timer = setInterval(checkAndNotify, 200);
  }
  
  // Первоначальная проверка
  checkAndNotify();
  
  window.addEventListener('beforeunload', function() {
    ob && ob.disconnect();
    timer && clearInterval(timer);
  });
})();
''');

                          /*  double height = h!.toDouble();
                           sl<ScrollHeightCubit>()
                            .updateScrollHeight(height);
                          print('высота: $h');*/
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*CustomScrollView(
slivers: [
SliverOverlapAbsorber(
handle: SliverOverlapAbsorberHandle(),
sliver: SliverSafeArea(
sliver: SliverAppBar(
expandedHeight: 220,
collapsedHeight: 56,
pinned: true,
flexibleSpace: Stack(
children: [
FlexibleSpaceBar(
titlePadding: EdgeInsets.only(right: 0),
collapseMode: CollapseMode.pin,
background: Container(
color: Colors.white,
child: Image.asset(
'assets/images/titleimage.png',
fit: BoxFit.cover,
),
)),
],
)),
),
),
ValueListenableBuilder(
valueListenable: scrollHeightNotifier,
builder: (context, scrollHeight, child) {
return SliverToNestedScrollBoxAdapter(
childExtent: scrollHeight,
onScrollOffsetChanged: (scrollOffset) {
double y = scrollOffset;
print('scroll: $y');
if (Platform.isAndroid) {
y *= View.of(context).devicePixelRatio;
}
webViewController.scrollTo(0, y.ceil());
},
child: WebViewWidget(
controller: webViewController));
}),

],
)*/

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
