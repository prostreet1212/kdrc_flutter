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

enum ScrollStatus { prev, forward }

class WebPage extends StatefulWidget {
  WebPage({Key? key}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  final ScrollController scrollController = ScrollController();
  late WebViewController webViewController;
  bool _isCollapsed  = false;
  bool isforward=true;
  ScrollStatus scrollStatus=ScrollStatus.forward;
  double oldScroll=0.0;




  @override
  void initState() {
    super.initState();

    webViewController = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
onNavigationRequest: (r){
  scrollStatus=ScrollStatus.forward;
  print('Навигация вперед');
  oldScroll=scrollController.offset;
            return NavigationDecision.navigate;
},

          onPageStarted: (url) {
int a=0;
          },
          onPageFinished: (url) async {

            print('Позиция scrollController ${scrollController.position}');
            webViewController.runJavaScript(Utils.scrollHeightJs);
            if(scrollStatus==ScrollStatus.forward){
              if(scrollController.offset>220){
                scrollController.jumpTo(220);
              }

            }else{
              if(scrollController.offset>220){
                scrollController.jumpTo(oldScroll);
              }
            }

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
            //webViewController.scrollTo(0, 0);
            //scrollController.jumpTo(0);
          })
      ..loadRequest(Uri.parse(
          'https://kdrc.ru'));
    scrollController.addListener((){
      setState(() {
        _isCollapsed = scrollController.offset > 112;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('страница');
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController.canGoBack()) {
          scrollStatus=ScrollStatus.prev;
          webViewController.goBack();
          print('Навигация назад');
          return false;
        }else{
          return true;
        }

      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: <Widget>[
              CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  CustomAppBar(isCollapsed: _isCollapsed,),
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


