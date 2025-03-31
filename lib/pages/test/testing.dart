import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kdrc_flutter/cubits/scroll_height_cubit.dart';
import 'package:nested_scroll_view_plus/nested_scroll_view_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';


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
  late WebViewController webViewController;
  //final GlobalKey<NestedScrollViewState> myKey = GlobalKey();
  ScrollStatus scrollStatus = ScrollStatus.forward;
  double oldScroll = 0.0;

  //double prevPixel=0;
  List<double> prevPixels = [];
  String prevUrl = '';

  late InAppWebViewController _webViewController;
  late final PlatformWebViewController _controller;


  @override
  void initState() {
    super.initState();
      webViewController = WebViewController()
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
      })
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        //Uri.parse('https://kdrc.ru/novosti'),
        //Uri.parse('https://kdrc.ru'),
        Uri.parse('https://flutter.dev'),
      );
  }


  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (c) => sl<ScrollHeightCubit>(),
      child: WillPopScope(
        onWillPop: () async {
          if (await webViewController.canGoBack()) {
            scrollStatus = ScrollStatus.prev;
            webViewController.goBack();

          }
          return false;
        },
        child: SafeArea(
          child: Scaffold(
            body: NestedScrollView(
              //controller: controller,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                    handle: SliverOverlapAbsorberHandle(),
                    sliver: SliverSafeArea(
                      sliver: SliverAppBar(
                        stretch: true,
                        stretchTriggerOffset: 100,
                        expandedHeight: 256,
                        collapsedHeight: 56,
                        pinned: true,
                      ),
                    ),
                  ),
                ];
              },
              body: CustomScrollView(
                key:PageStorageKey('webview-scroll'),
                slivers: [
                  SliverToNestedScrollBoxAdapter(
                      childExtent: 2500,
                      onScrollOffsetChanged: (scrollOffset) {
                        double y = scrollOffset;
                        if (Platform.isAndroid) {
                          y *= View.of(context).devicePixelRatio;
                        }
                        webViewController.scrollTo( 0, y.ceil());

                      },
                      child:WebViewWidget(controller: webViewController,)
                  ),
                ],
              ),),
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
