import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:kdrc_flutter/utils/utils.dart';
import 'package:nested_scroll_controller/nested_scroll_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum ScrollStatus { prev, forward }

class NestedWebviewController {
  NestedWebviewController(this.initialUrl);

  final String initialUrl;
  WebViewController? _webViewController;
  WebViewController? get webViewController => _webViewController;

  ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1);
  late NestedScrollController nestedScrollController = NestedScrollController();
  ScrollStatus scrollStatus = ScrollStatus.forward;
  double oldScroll = 0.0;


  //double prevPixel=0;
  List<double> prevPixels = [];
  String prevUrl = '';

  void init(){
_webViewController=WebViewController()
  ..setNavigationDelegate(
    NavigationDelegate(onNavigationRequest: (r) {
      print('onPageSRequest');
      if (Platform.isAndroid) {
        scrollStatus = ScrollStatus.forward;
      }
      return NavigationDecision.navigate;
    }, onPageStarted: (url) {
      print('onPageStarted');
      if (scrollStatus == ScrollStatus.forward) {
        prevPixels.add(
            nestedScrollController.innerScrollController!.position.pixels);
      } else {
        oldScroll = prevPixels.last;
        prevPixels.removeLast();
      }
    }, onPageFinished: (url) async {
      print('onPageFinished');
      await _webViewController!.runJavaScript(Utils.scrollHeightJs);
      if (scrollStatus == ScrollStatus.forward) {
        if (nestedScrollController.innerScrollController!.offset > 0) {
          nestedScrollController.innerScrollController!.jumpTo(0);
        }
      } else {
        //Timer(Duration(milliseconds: 100), () {
          nestedScrollController.innerScrollController!.position
              .setPixels(oldScroll);

        //});
      }
      if (Platform.isIOS) {
        scrollStatus = ScrollStatus.forward;
      }
    }, onProgress: (progress) {
      print('$progress');
    }),
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
    Uri.parse(initialUrl),
  );



  }
}