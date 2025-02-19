

import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nested_scroll_view_plus/nested_scroll_view_plus.dart';

import '../utils/utils.dart';

class NestedPlus extends StatefulWidget {
  const NestedPlus({super.key});

  @override
  State<NestedPlus> createState() => _NestedPlusState();
}

class _NestedPlusState extends State<NestedPlus> {
  ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1);
  late WebViewController webViewController;

  final GlobalKey<NestedScrollViewStatePlus> myKey = GlobalKey();
  bool toggle=true;
  @override
  void initState() {
    super.initState();
    webViewController=WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
          onPageFinished: (url){
            webViewController.runJavaScript(Utils.scrollHeightJs);

          }
      ))
      ..addJavaScriptChannel('ScrollHeightNotifier',
          onMessageReceived: (message) {
            final String msg = message.message;
            final double? height = double.tryParse(msg);
            if (height != null) {
              scrollHeightNotifier.value = height;

            }
            //webViewController.scrollTo(0, 0);
            //scrollController.jumpTo(0);
          })
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://kdrc.ru'),);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // use GlobalKey<NestedScrollViewStatePlus> to access inner or outer scroll controller
      myKey.currentState?.innerController.addListener(() {
        final innerController = myKey.currentState!.innerController;

        if (innerController.positions.length == 1) {
          print(
              'Scrolling inner nested scrollview: ${innerController.offset} max: ${innerController.position.maxScrollExtent}');
        }
      });
      myKey.currentState?.outerController.addListener(() {
        final outerController = myKey.currentState!.outerController;
        if (outerController.positions.length == 1) {
          print(
              'Scrolling outer nested scrollview: ${outerController.offset} max: ${outerController.position.maxScrollExtent}  min: ${outerController.position.minScrollExtent}');
        }
      });
    });



  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController.canGoBack()) {
          webViewController.goBack();
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollViewPlus(
            physics: toggle?BouncingScrollPhysics(parent: BouncingScrollPhysics()): NeverScrollableScrollPhysics(
              parent: NeverScrollableScrollPhysics(),
            ),
            key: myKey,
            overscrollBehavior: OverscrollBehavior.inner,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
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
                                )
                              /*Image.asset(
                              'assets/images/titleimage.png',
                              fit: BoxFit.cover,
                            ),*/
                            ),
                          ],
                        )),
                  ),
                ),
              ];
            },
            body: CustomScrollView(
              key: PageStorageKey<String>('123'),
              physics: const NeverScrollableScrollPhysics(
                parent: NeverScrollableScrollPhysics(),
              ),
              //controller: customController,
              slivers: [
                SliverToNestedScrollBoxAdapter(
                    childExtent: 1500,
                    onScrollOffsetChanged: (scrollOffset) {
                      double y = scrollOffset;
                      print('scroll: $y');
                      if (Platform.isAndroid) {
                        y *= View.of(context).devicePixelRatio;
                      }
                      //webViewController.scrollTo(0, y.ceil());
                      webViewController.scrollTo(0, y.ceil());
                    },
                    child: WebViewWidget(
                      /* gestureRecognizers: Set()
                          ..add(Factory<VerticalDragGestureRecognizer>(
                              () => VerticalDragGestureRecognizer())),*/
                        controller: webViewController)
                  /*InAppWebView(
                     /* gestureRecognizers: Set()
                        ..add(Factory<PanGestureRecognizer>(
                                () => PanGestureRecognizer())),*/
                      initialUrlRequest: URLRequest(url: WebUri("https://kdrc.ru/")),
                      onWebViewCreated: (controller) {
                        qontroller = controller;
                        qontroller.getContentHeight().then((s) {
                          //scrollHeightNotifier.value=s!.toDouble();
                          print('высота: ${s}');
                        });
                      },
                    ),*/
                )
                // ValueListenableBuilder(
                //     valueListenable: scrollHeightNotifier,
                //     builder: (context,scrollHeight,child){
                //       return SliverToNestedScrollBoxAdapter(
                //           childExtent: scrollHeight,
                //           onScrollOffsetChanged: (scrollOffset) {
                //             double y = scrollOffset;
                //             print('scroll: $y');
                //             if (Platform.isAndroid) {
                //               y *= View.of(context).devicePixelRatio;
                //             }
                //             //webViewController.scrollTo(0, y.ceil());
                //             webViewController.scrollTo(0, y.ceil());
                //           },
                //           child: WebViewWidget(
                //             /* gestureRecognizers: Set()
                //           ..add(Factory<VerticalDragGestureRecognizer>(
                //               () => VerticalDragGestureRecognizer())),*/
                //               controller: webViewController)
                //         /*InAppWebView(
                //      /* gestureRecognizers: Set()
                //         ..add(Factory<PanGestureRecognizer>(
                //                 () => PanGestureRecognizer())),*/
                //       initialUrlRequest: URLRequest(url: WebUri("https://kdrc.ru/")),
                //       onWebViewCreated: (controller) {
                //         qontroller = controller;
                //         qontroller.getContentHeight().then((s) {
                //           //scrollHeightNotifier.value=s!.toDouble();
                //           print('высота: ${s}');
                //         });
                //       },
                //     ),*/
                //       );
                //     })
              ],
            ),
          ),

          /* WebViewWidget(
              gestureRecognizers:  Set()..add(Factory<VerticalDragGestureRecognizer>(()
              => VerticalDragGestureRecognizer())),
              controller:webViewController
            ),*/
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                  onPressed: () {
                    myKey.currentState?.innerController.jumpTo(800);
                    //myKey.currentState?.outerController.jumpTo(200);
                    //webViewController.scrollTo(0, 400);
              }),
              FloatingActionButton(
                  onPressed: () {
                //myKey.currentState?.outerController.jumpTo(200);
                    setState(() {
                      toggle=!toggle;
                    });
                //customController.jumpTo(200);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
