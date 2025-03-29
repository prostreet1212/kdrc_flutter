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
import 'package:sliver_tools/sliver_tools.dart';

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
  //final GlobalKey<NestedScrollViewState> myKey = GlobalKey();
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

  final GlobalKey<NestedScrollViewState> sliverKey = GlobalKey();
  var controller=ScrollController();
  var controller2=ScrollController();
  SliverOverlapAbsorberHandle _sliverHandle = SliverOverlapAbsorberHandle();


  @override
  Widget build(BuildContext context) {
    bool a = false;
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
            backgroundColor: Colors.green,
            body:NestedScrollView(
              //controller: controller,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  a = innerBoxIsScrolled;
                  return [
                    SliverOverlapAbsorber(
                      handle: _sliverHandle,
                      sliver: SliverSafeArea(
                          sliver: SliverAppBar(
                        expandedHeight: 256,
                        collapsedHeight: 56,
                        pinned: true,
                      ),
                      ),
                    ),
                  ];
                },
                body: CustomScrollView(
                  slivers: [
                   SliverToNestedScrollBoxAdapter(
                      childExtent: 1491,
                      onScrollOffsetChanged: (scrollOffset) {
                        double y = scrollOffset;
                        if (Platform.isAndroid) {
                          y *= View.of(context).devicePixelRatio;
                        }
                        _webViewController.scrollTo(x: 0, y: y.ceil());
                      },
                      child: SizedBox(
                        height: 1491,
                        child: InAppWebView(
                          initialUrlRequest: URLRequest(
                            url: WebUri('https://flutter.dev'),
                            //url: WebUri('https://kdrc.ru/novosti'),
                          ),
                          onWebViewCreated: (controller) {
                            _webViewController = controller;
                          },
                          initialSettings: InAppWebViewSettings(
                            useShouldOverrideUrlLoading: true,
                            allowsInlineMediaPlayback: true,
                            javaScriptEnabled: true,
                            preferredContentMode:
                            UserPreferredContentMode.MOBILE,
                          ),
                          onLoadStop: (controller, url) async {
                            print('STOP');
                            controller.evaluateJavascript(source: source);
                          },
                        ),
                      ),
                    ),



                  ],
                ),
          ),
        ),
      ),
    ));
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
