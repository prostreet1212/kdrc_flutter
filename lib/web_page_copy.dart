import 'dart:ffi';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/scroll_height_cubit.dart';
import 'package:kdrc_flutter/utils/utils.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:ui';

class WebPageCopy extends StatelessWidget {
   WebPageCopy({super.key});

   final ScrollController scrollController = ScrollController();
  late WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    webViewController = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (url) {},
          onPageFinished: (a) {
            print('Позиция scrollController ${scrollController.position}');
            webViewController.runJavaScript(Utils.scrollHeightJs);
          },
          onWebResourceError: (e) {
            //print('ERROR: ${e.errorCode}');
          },
          onProgress: (progress) {}))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('ScrollHeightNotifier',
          onMessageReceived: (message) {
            final String msg = message.message;
            final double? height = double.tryParse(msg);
            if (height != null) {
              //scrollHeightNotifier.value = height;
              context.read<ScrollHeightCubit>().updateScrollHeight(height);
            }
            webViewController.scrollTo(0, 0);
            //scrollController.jumpTo(0);
          })
      ..loadRequest(Uri.parse(
          'https://yandex.ru/support/yandex-360/customers/purchase/ru/'));
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController.canGoBack()) {
          webViewController.goBack();
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  CustomAppBar(),
                  BlocBuilder<ScrollHeightCubit, double>(
                      builder: (context,state){
                        print('state: $state');
                        return SliverToNestedScrollBoxAdapter(
                          childExtent: state,
                          onScrollOffsetChanged: (double scrollOffset) {
                            double y = scrollOffset;
                            print('scroll: $y');
                            if (Platform.isAndroid) {
                              y *= View
                                  .of(context)
                                  .devicePixelRatio;
                            }
                            webViewController.scrollTo(0, y.ceil());
                          },
                          child: WebViewWidget(controller: webViewController),
                        );
                      }),
                  // ValueListenableBuilder<double>(
                  //     valueListenable: scrollHeightNotifier,
                  //     builder: (BuildContext context,
                  //         double scrollHeight,
                  //         Widget? child,) {
                  //       return SliverToNestedScrollBoxAdapter(
                  //         childExtent: scrollHeight,
                  //         onScrollOffsetChanged: (double scrollOffset) {
                  //           double y = scrollOffset;
                  //           print('scroll: $y');
                  //           if (Platform.isAndroid) {
                  //             y *= View
                  //                 .of(context)
                  //                 .devicePixelRatio;
                  //           }
                  //           webViewController.scrollTo(0, y.ceil());
                  //         },
                  //         child: child,
                  //       );
                  //     },
                  //     child: WebViewWidget(
                  //       /* gestureRecognizers: Set()
                  //         ..add(
                  //           Factory<VerticalDragGestureRecognizer>(
                  //               () => VerticalDragGestureRecognizer()),
                  //         ),*/
                  //         controller: webViewController)),
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
              onPressed: () {
                // webViewController.scrollTo(0, 0);
                // scrollController.jumpTo(0);
                Utils.showCallDialog(context);
              }),
        ),
      ),
      // )
    );
  }
}





