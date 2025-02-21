import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

// class OnlyWeb extends StatefulWidget {
//   const OnlyWeb({super.key});
//
//   @override
//   State<OnlyWeb> createState() => _OnlyWebState();
// }
//
// class _OnlyWebState extends State<OnlyWeb> {
//
//   late WebViewController webViewController;
//
//   @override
//   void initState() {
//     super.initState();
//     webViewController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(NavigationDelegate(
//         onPageFinished: (url){
//           print('финиш');
//         }
//       ))
//       ..loadRequest(
//         //Uri.parse('https://kdrc.ru/novosti'),
//         Uri.parse('https://kdrc.ru'),
//       );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: ()async{
//         if(await webViewController.canGoBack()){
//           webViewController.goBack();
//           return false;
//         }else{
//           return true;
//         }
//       },
//       child: Scaffold(
//         body: WebViewWidget(controller: webViewController),
//       ),
//     );
//   }
// }

class OnlyInWeb extends StatefulWidget {
  const OnlyInWeb({super.key});

  @override
  State<OnlyInWeb> createState() => _OnlyInWebState();
}

class _OnlyInWebState extends State<OnlyInWeb> {
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true,
      javaScriptEnabled: true);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
      if(await webViewController!.canGoBack()){
          webViewController!.goBack();
          return false;
        }else{
          return true;
        }
      },
      child: Scaffold(
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri("https://kdrc.ru/novosti")),
          initialSettings: settings,
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStop: (controller, url) {
            print('финиш');
          },
        ),
      ),
    );
  }
}
