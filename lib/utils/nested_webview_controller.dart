import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/cubits/is_collapsed_cubit.dart';
import 'package:kdrc_flutter/utils/utils.dart';
import 'package:nested_scroll_controller/nested_scroll_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../cubits/scroll_height_cubit.dart';
import '../locator_service.dart';
import '../main.dart';
import '../widgets/custom_appbar.dart';

enum ScrollStatus { prev, forward }

class NestedWebviewController {
  NestedWebviewController({required this.initialUrl, required this.context});

  final String initialUrl;
  BuildContext context;

  WebViewController? _webViewController;

  WebViewController? get webViewController => _webViewController;

  //ValueNotifier<double> scrollHeightNotifier = ValueNotifier<double>(1);
  late NestedScrollController nestedScrollController = NestedScrollController();
  ScrollStatus scrollStatus = ScrollStatus.forward;
  double oldScroll = 0.0;

  //double prevPixel=0;
  List<double> prevPixels = [];
  String prevUrl = '';

  static var httpClient = new HttpClient();
  Future<File> _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  void init() {
    _webViewController = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(onNavigationRequest: (request) async{
          print('onPageSRequest');
          if(request.url.contains('.pdf')){
            await _downloadFile(request.url, 'скачанный файл');
            return NavigationDecision.prevent;
          }else{
            if (Platform.isAndroid) {
              scrollStatus = ScrollStatus.forward;
            }
            return NavigationDecision.navigate;
          }


        }, onPageStarted: (url) {
          print('onPageStarted');
          sl<BoolCubit>().changeValue(true);
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
              nestedScrollController.innerScrollController!.position.setPixels(0);
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
          sl<BoolCubit>().changeValue(false);
        },
            onProgress: (progress) {
          print('$progress');
        },
        onWebResourceError: (error){
          print('ошибка: ${error.errorType}');
          print('ошибка: ${error.description}');

        }),
      )
      ..addJavaScriptChannel('ScrollHeightNotifier',
          onMessageReceived: (message) {
        final String msg = message.message;
        final double? height = double.tryParse(msg);
        if (height != null) {
          sl<ScrollHeightCubit>().updateScrollHeight(height);
         //scrollHeightCubit.updateScrollHeight(height);
        }
      })
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(initialUrl),
      );

    nestedScrollController.addListener(() {
      if (nestedScrollController.offset > 112) {
        if (sl<IsCollapsedCubit>().state != true) {
          sl<IsCollapsedCubit>().updateIsCollapsed(true);
        }
      } else {
        if (sl<IsCollapsedCubit>().state != false) {
          sl<IsCollapsedCubit>().updateIsCollapsed(false);
        }
      }
    });
  }
}
