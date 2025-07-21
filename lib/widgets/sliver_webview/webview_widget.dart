import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
    return InAppWebView(
      onWebViewCreated: (c) {
        sl<NestedWebviewController>().onWebViewCreated(c);
      },
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        transparentBackground: true,
        useShouldOverrideUrlLoading: true,
        useOnRenderProcessGone: true,
        allowsBackForwardNavigationGestures: false,
        //mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        //userAgent: 'Mozilla/5.0 (Linux; Android 10; Mobile)',
        cacheEnabled: false,
        cacheMode: CacheMode.LOAD_NO_CACHE,
        clearCache: true
        /*disableVerticalScroll: true,
        disableHorizontalScroll: true,
        disallowOverScroll: true,*/
      ),
      initialUrlRequest: URLRequest(url: WebUri(sl<StartCubit>().state.url)),

      /* gestureRecognizers: Platform.isIOS?{
       /* Factory<HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(),)*/
        /*Factory<ConditionalHorizontalDragRecognizer>(
              () => ConditionalHorizontalDragRecognizer(),),*/
        Factory<AllowMultipleHorizontalDragRecognizer>(
              () => AllowMultipleHorizontalDragRecognizer(),
        ),
      }:{},*/
      onLoadStart: (c, uri) {
        sl<NestedWebviewController>().onLoadStart(c, uri);
      },
      onLoadStop: (c, uri) {
        sl<NestedWebviewController>().onLoadStop(c, uri);
      },
      onProgressChanged: (c, progress) {
        sl<NestedWebviewController>().onProgressChanged(c, progress);
      },
      //раскоментить
      shouldOverrideUrlLoading: (c, navigationAction) async {
        return sl<NestedWebviewController>().shouldOverrideUrlLoading(
          c,
          navigationAction,
          di.sl<NestedWebviewController>().fToast,
          context,
        );
      },
      onReceivedError: (c, request, error) {
        sl<NestedWebviewController>().onReceivedError(error);
      },
      onRenderProcessGone: (c, details) async {
        log('onRenderProcessGone: $details');
        sl<NestedWebviewController>().isCrashed = true;
      },
      onWebContentProcessDidTerminate: (c) {
        log('onWebContentProcessDidTerminate');
      },
      onReceivedHttpError: (c, request, response) {},
    );
  }
}

class ConditionalHorizontalDragRecognizer
    extends HorizontalDragGestureRecognizer {
  @override
  void handleEvent(PointerEvent event) {
    // Проверяем угол движения (45 градусов)
    if (event is PointerMoveEvent) {
      final delta = event.delta;
      final angle = (atan2(delta.dy, delta.dx) * 180 / pi).abs();

      // Блокируем вертикальные движения
      if (angle > 45 && angle < 135) {
        return;
      }
    }
    super.handleEvent(event);
  }
}

class AllowMultipleHorizontalDragRecognizer
    extends HorizontalDragGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    // Не блокирует другие распознаватели при отклонении жеста
    acceptGesture(pointer);

  }
}
