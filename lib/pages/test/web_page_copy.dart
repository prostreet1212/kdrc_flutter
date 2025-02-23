import 'dart:ffi';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_direct_call_plus/flutter_direct_call.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kdrc_flutter/cubits/scroll_height_cubit.dart';
import 'package:kdrc_flutter/utils/utils.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:ui';

class WebPageCopy extends StatefulWidget {
   WebPageCopy({super.key});

  @override
  State<WebPageCopy> createState() => _WebPageCopyState();
}

class _WebPageCopyState extends State<WebPageCopy> {
   ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1000);
   final ScrollController scrollController = ScrollController();
  late InAppWebViewController webViewController;

  @override
  void initState() {
    super.initState();

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
          body: Stack(
            children: <Widget>[
              CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  CustomAppBar(isCollapsed: true,),
                  ValueListenableBuilder<double>(
                      valueListenable: scrollHeightNotifier,
                      builder: (BuildContext context,
                          double scrollHeight,
                          Widget? child,) {
                        return SliverToNestedScrollBoxAdapter(
                          childExtent: scrollHeight,
                          onScrollOffsetChanged: (double scrollOffset) {
                            double y = scrollOffset;
                            print('scroll: $y');
                            if (Platform.isAndroid) {
                              y *= View
                                  .of(context)
                                  .devicePixelRatio;
                            }
                            //webViewController.scrollTo(0, y.ceil());
                            webViewController.scrollTo(x: 0, y: y.ceil());

                          },
                          child: child,
                        );
                      },
                      child: InAppWebView(

                        initialUrlRequest:
                        URLRequest(url: WebUri("https://kdrc.ru/")),
                        onWebViewCreated: (controller) {
                          webViewController = controller;
                          webViewController.getContentHeight().then((s){
                            //scrollHeightNotifier.value=s!.toDouble();
                            print('высота: ${s}');
                          });


                        },
                      )),
                ],
              ),
            ],
          ),
floatingActionButton: FloatingActionButton(
    onPressed: (){
      scrollController.jumpTo(220);
    }),
        ),
      ),
      // )
    );
  }
}





