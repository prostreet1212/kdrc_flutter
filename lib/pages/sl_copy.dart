import 'dart:async';
import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nested_scroll_controller/nested_scroll_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/utils.dart';

enum ScrollStatus { prev, forward }


class SlWebCopy extends StatefulWidget {
  const SlWebCopy({super.key});

  @override
  State<SlWebCopy> createState() => _SlWebCopyState();
}

class _SlWebCopyState extends State<SlWebCopy> {
  ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1);
  late WebViewController webViewController;
  final GlobalKey<NestedScrollViewState> myKey = GlobalKey();
  ScrollStatus scrollStatus = ScrollStatus.forward;
  double oldScroll = 0.0;

  //double prevPixel=0;
  List<double> prevPixels = [];
  String prevUrl = '';

  late NestedScrollController nestedScrollController=NestedScrollController();


  @override
  void initState() {
    super.initState();
    nestedScrollController.addListener(() {
      print("Outer: ${nestedScrollController.offset}");
      print("Inner: ${nestedScrollController.innerOffset}");
      print("Total: ${nestedScrollController.totalOffset}");
    });
    webViewController = WebViewController()
      ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (url)async{
              await webViewController.runJavaScript(Utils.scrollHeightJs);
            }
          ))
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
        Uri.parse('https://kdrc.ru'),
      );


  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController.canGoBack()) {
          //scrollStatus = ScrollStatus.prev;
          webViewController.goBack();
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          /* body:  WebViewWidget(
            /* gestureRecognizers: Set()
                        ..add(Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer())),*/
              controller: webViewController),*/
          body: NestedScrollView(
            controller: nestedScrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
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
                                )),
                          ],
                        )),
                  ),
                ),
              ];
            },
            body: LayoutBuilder(builder: (context, constraints){
              nestedScrollController.enableScroll(context);
              //nestedScrollController.enableCenterScroll(constraints);
              return CustomScrollView(
                //controller: customController,
                slivers: [
                  ValueListenableBuilder(
                      valueListenable: scrollHeightNotifier,
                      builder: (context, scrollHeight, child) {
                        return SliverToNestedScrollBoxAdapter(
                            childExtent: scrollHeight,
                            onScrollOffsetChanged: (scrollOffset) {
                              double y = scrollOffset;
                              print('scroll: $y');
                              if (Platform.isAndroid) {
                                y *= View
                                    .of(context)
                                    .devicePixelRatio;
                              }
                              webViewController.scrollTo(0, y.ceil());
                            },
                            child: WebViewWidget(
                              /* gestureRecognizers: Set()
                        ..add(Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer())),*/
                                controller: webViewController));
                      })
                ],
              );
            }),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(onPressed: () {
                nestedScrollController.position.setPixels(30);
              }),
              FloatingActionButton(onPressed: () {
                nestedScrollController.innerScrollController!.position.setPixels(50);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// class SlWebCopy extends StatefulWidget {
//   const SlWebCopy({super.key});
//
//   @override
//   State<SlWebCopy> createState() => _SlWebCopyState();
// }
//
// class _SlWebCopyState extends State<SlWebCopy> {
//   ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1);
//    ScrollController nestedController = ScrollController();
//   late WebViewController webViewController;
//   final GlobalKey<NestedScrollViewState> myKey = GlobalKey();
//   ScrollStatus scrollStatus = ScrollStatus.forward;
//   double oldScroll = 0.0;
//
//   //double prevPixel=0;
//   List<double> prevPixels = [];
//   String prevUrl = '';
//
//
//   @override
//   void initState() {
//     super.initState();
//     webViewController = WebViewController()
//       ..setNavigationDelegate(
//         NavigationDelegate(
//             onNavigationRequest: (r) {
//               print('onPageSRequest');
//               if (Platform.isAndroid) {
//                 scrollStatus = ScrollStatus.forward;
//               }
//               return NavigationDecision.navigate;
//             },
//             onPageStarted: (url) {
//               print('onPageStarted');
//               if (scrollStatus == ScrollStatus.forward) {
//                 prevPixels.add(
//                     myKey.currentState!.innerController.position.pixels);
//               } else {
//                 oldScroll = prevPixels.last;
//                 prevPixels.removeLast();
//               }
//             },
//             onPageFinished: (url) async {
//               print('onPageFinished');
//               await webViewController.runJavaScript(Utils.scrollHeightJs);
//               if (scrollStatus == ScrollStatus.forward) {
//                 if (myKey.currentState!.innerController.offset > 0) {
//                   myKey.currentState!.innerController.jumpTo(0);
//                 }
//               } else {
//                 Timer(Duration(milliseconds: 100), () {
//                   myKey.currentState!.innerController.position.setPixels(
//                       oldScroll);
//                   //prevPixels.removeAt(prevPixels.length-1);
//                 });
//                 // myKey.currentState!.innerController.position.setPixels(prevPixels[prevPixels.length-1]);
//                 //prevPixels.removeAt(prevPixels.length-1);
//               }
//               if (Platform.isIOS) {
//                 scrollStatus = ScrollStatus.forward;
//               }
//
//             },
//             onProgress: (progress) {
//               print('$progress');
//             }),)
//       ..addJavaScriptChannel('ScrollHeightNotifier',
//           onMessageReceived: (message) {
//             final String msg = message.message;
//             final double? height = double.tryParse(msg);
//             if (height != null) {
//               scrollHeightNotifier.value = height;
//             }
//             //scrollController.jumpTo(0);
//           })
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(
//         //Uri.parse('https://kdrc.ru/novosti'),
//         Uri.parse('https://kdrc.ru'),
//       );
//
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       // use GlobalKey<NestedScrollViewStatePlus> to access inner or outer scroll controller
//       myKey.currentState?.innerController.addListener(() {
//         final innerController = myKey.currentState!.innerController;
//
//         if (innerController.positions.length == 1) {
//           print(
//               'Scrolling inner nested scrollview: ${innerController
//                   .offset} max: ${innerController.position.maxScrollExtent}');
//         }
//       });
//       myKey.currentState?.outerController.addListener(() {
//         final outerController = myKey.currentState!.outerController;
//         if (outerController.positions.length == 1) {
//           print(
//               'Scrolling outer nested scrollview: ${outerController
//                   .offset} max: ${outerController.position
//                   .maxScrollExtent}  min: ${outerController.position
//                   .minScrollExtent}');
//         }
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (await webViewController.canGoBack()) {
//           scrollStatus = ScrollStatus.prev;
//           webViewController.goBack();
//         }
//         return false;
//       },
//       child: SafeArea(
//         child: Scaffold(
//           /* body:  WebViewWidget(
//             /* gestureRecognizers: Set()
//                         ..add(Factory<VerticalDragGestureRecognizer>(
//                             () => VerticalDragGestureRecognizer())),*/
//               controller: webViewController),*/
//           body: NestedScrollView(
//             //controller: nestedController,
//             key: myKey,
//             headerSliverBuilder:
//                 (BuildContext context, bool innerBoxIsScrolled) {
//               return [
//                 SliverOverlapAbsorber(
//                   handle: SliverOverlapAbsorberHandle(),
//                   sliver: SliverSafeArea(
//                     sliver: SliverAppBar(
//                         expandedHeight: 220,
//                         collapsedHeight: 56,
//                         pinned: true,
//                         flexibleSpace: Stack(
//                           children: [
//                             FlexibleSpaceBar(
//                                 titlePadding: EdgeInsets.only(right: 0),
//                                 collapseMode: CollapseMode.pin,
//                                 background: Container(
//                                   color: Colors.white,
//                                   child: Image.asset(
//                                     'assets/images/titleimage.png',
//                                     fit: BoxFit.cover,
//                                   ),
//                                 )),
//                           ],
//                         )),
//                   ),
//                 ),
//               ];
//             },
//             body: CustomScrollView(
//               //controller: customController,
//               slivers: [
//                 ValueListenableBuilder(
//                     valueListenable: scrollHeightNotifier,
//                     builder: (context, scrollHeight, child) {
//                       return SliverToNestedScrollBoxAdapter(
//                           childExtent: scrollHeight,
//                           onScrollOffsetChanged: (scrollOffset) {
//                             double y = scrollOffset;
//                             print('scroll: $y');
//                             if (Platform.isAndroid) {
//                               y *= View
//                                   .of(context)
//                                   .devicePixelRatio;
//                             }
//                             webViewController.scrollTo(0, y.ceil());
//                           },
//                           child: WebViewWidget(
//                             /* gestureRecognizers: Set()
//                         ..add(Factory<VerticalDragGestureRecognizer>(
//                             () => VerticalDragGestureRecognizer())),*/
//                               controller: webViewController));
//                     })
//               ],
//             ),
//           ),
//           floatingActionButton: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               FloatingActionButton(onPressed: () {
//                 // myKey.currentState!.innerController.jumpTo(10);
//
//                 myKey.currentState!.innerController.position.setPixels(50);
//                 //myKey.currentState!.innerController.position.pixels;
//               }),
//               FloatingActionButton(onPressed: () {
//                 //myKey.currentState!.outerController.position.setPixels(50);
//                 //nestedController.jumpTo(220);
//                 //webViewController.scrollTo(0, 100);
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
