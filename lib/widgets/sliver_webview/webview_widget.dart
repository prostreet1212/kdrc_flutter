import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../cubits/start_cubit/start_cubit.dart';
import '../../locator_service.dart';
import '../../locator_service.dart' as di;
import '../../utils/nested_webview_controller.dart';

class WebViewVidget extends StatelessWidget {
   const WebViewVidget({super.key});


  @override
  Widget build(BuildContext context) {
    return   InAppWebView(
      onWebViewCreated: (c) {
        sl<NestedWebviewController>()
            .onWebViewCreated(c);
      },
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        transparentBackground: true,
        useShouldOverrideUrlLoading: true,
        useOnRenderProcessGone: true,
        //  allowsBackForwardNavigationGestures: true,
      ),
      initialUrlRequest: URLRequest(
        url: WebUri(
          sl<StartCubit>().state.url,
        ),
      ),
      onLoadStart: (c, uri) {
        sl<NestedWebviewController>()
            .onLoadStart(c, uri);
      },
      onLoadStop: (c, uri) {
        sl<NestedWebviewController>()
            .onLoadStop(c, uri);
      },
      onProgressChanged: (c, progress) {
        sl<NestedWebviewController>()
            .onProgressChanged(c, progress);
      },
      //раскоментить
      shouldOverrideUrlLoading:
          (c, navigationAction) async {
        return sl<
            NestedWebviewController
        >()
            .shouldOverrideUrlLoading(
          c,
          navigationAction,
          di.sl<NestedWebviewController>().fToast,
          context,
        );
      },
      onReceivedError: (c, request, error) {
        sl<NestedWebviewController>()
            .onReceivedError(error);
      },
      onRenderProcessGone:
          (c, details) async {
        log(
          'onRenderProcessGone: $details',
        );
        sl<NestedWebviewController>()
            .isCrashed =
        true;
      },
      onWebContentProcessDidTerminate: (c) {
        log(
          'onWebContentProcessDidTerminate',
        );
      },
      onReceivedHttpError:
          (c, request, response) {},
    );
  }
}
