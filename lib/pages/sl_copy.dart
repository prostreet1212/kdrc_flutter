import 'dart:async';
import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:nested_scroll_controller/nested_scroll_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/utils.dart';



class SlWebCopy extends StatefulWidget {
  const SlWebCopy({super.key});

  @override
  State<SlWebCopy> createState() => _SlWebCopyState();
}

class _SlWebCopyState extends State<SlWebCopy> {

  NestedWebviewController nestedWebviewController=NestedWebviewController('https://kdrc.ru/novosti');
  bool isCollapsed  = false;

  @override
  void initState() {
    super.initState();
    nestedWebviewController.init();
    nestedWebviewController.nestedScrollController.addListener((){

      setState(() {
        isCollapsed = nestedWebviewController.nestedScrollController.offset > 112;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await nestedWebviewController.webViewController!.canGoBack()) {
          nestedWebviewController.scrollStatus = ScrollStatus.prev;
          nestedWebviewController.webViewController!.goBack();
        }
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollView(
            controller: nestedWebviewController.nestedScrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                CustomAppBar(isCollapsed: isCollapsed),
                /*
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
                ),*/
              ];
            },
            body: LayoutBuilder(builder: (context, constraints) {
              nestedWebviewController.nestedScrollController.enableScroll(context);
              return CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  ValueListenableBuilder(
                      valueListenable: nestedWebviewController.scrollHeightNotifier,
                      builder: (context, scrollHeight, child) {
                        return SliverToNestedScrollBoxAdapter(
                            childExtent: scrollHeight,
                            onScrollOffsetChanged: (scrollOffset) {
                              double y = scrollOffset;
                              print('scroll: $y');
                              if (Platform.isAndroid) {
                                y *= View.of(context).devicePixelRatio;
                              }
                              nestedWebviewController.webViewController!.scrollTo(0, y.ceil());
                            },
                            child:
                                WebViewWidget(controller: nestedWebviewController.webViewController!));
                      })
                ],
              );
            }),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(onPressed: () {
                // myKey.currentState!.innerController.jumpTo(10);
                //myKey.currentState!.innerController.position.setPixels(50);
                //myKey.currentState!.innerController.position.pixels;
              }),
              FloatingActionButton(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
