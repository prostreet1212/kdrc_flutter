import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/cubits/is_collapsed_cubit.dart';
import 'package:kdrc_flutter/pages/test/file_page.dart';
import 'package:kdrc_flutter/pages/test/pdf_page.dart';
import 'package:kdrc_flutter/utils/utils.dart';
import 'package:kdrc_flutter/widgets/file_loading_dialog.dart';
import 'package:nested_scroll_controller/nested_scroll_controller.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../cubits/background_cubit.dart';
import '../cubits/error_text_cubit.dart';
import '../cubits/scroll_height_cubit.dart';
import '../locator_service.dart';
import '../main.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_toast.dart';

enum ScrollStatus { prev, forward, reload }

class NestedWebviewController {
  NestedWebviewController({required this.initialUrl, required this.context});

  final String initialUrl;
  BuildContext context;

  WebViewController? _webViewController;

  WebViewController? get webViewController => _webViewController;

  late NestedScrollController nestedScrollController = NestedScrollController();
  ScrollStatus scrollStatus = ScrollStatus.forward;
  double oldScroll = 0.0;

  bool internetStatus = true;
  bool isFirstRun = true;
  bool isBackground = true;
  bool isBackgroundNoInternet = true;

  //double prevPixel=0;
  List<double> prevPixels = [];
  String prevUrl = '';


  late StreamSubscription<InternetStatus> internetListener;

  static var httpClient = new HttpClient();

  Future<File> _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse('${url}'));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  // void checkInternet() {
  //   internetListener = InternetConnection()
  //       .onStatusChange
  //       .listen((InternetStatus status) async {
  //     switch (status) {
  //       case InternetStatus.connected:
  //         //print('интернет подключен');
  //         if (isFirstRun && internetStatus == false) {
  //           sl<InternetCubit>().changeValue(true);
  //           scrollStatus = ScrollStatus.reload;
  //           webViewController!.reload();
  //           isFirstRun = false;
  //         } else {
  //           isFirstRun = false;
  //         }
  //         internetStatus = true;
  //         break;
  //       case InternetStatus.disconnected:
  //         //print('интернет отключен');
  //         internetStatus = false;
  //         if (isFirstRun && internetStatus == false) {
  //           sl<ScrollHeightCubit>().updateScrollHeight(0);
  //           sl<InternetCubit>().changeValue(false);
  //         }
  //         break;
  //     }
  //   });
  // }

  void init() {
    fToast.init(context);
    _webViewController = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(onNavigationRequest: (request) async {
          print('onPageSRequest');
          if (internetStatus) {
            if (!request.url.contains('kdrc.ru') ||
                request.url.contains('mailto:')) {
              launchUrl(Uri.parse(request.url));
              return NavigationDecision.prevent;
            } else {
              if (request.url.contains('.doc') ||
                  request.url.contains('.xls')) {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return FileLoadingDialog();
                    });
                File pdfFile = await _downloadFile(
                    request.url, 'file.${Utils.getTypeFile(request.url)}');
                Navigator.pop(context);
                OpenFilex.open(pdfFile.path);
                return NavigationDecision.prevent;
              } else if (request.url.contains('.pdf')) {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return FileLoadingDialog();
                    });
                File pdfFile = await _downloadFile(
                    request.url, 'file.${Utils.getTypeFile(request.url)}');
                Navigator.pop(context);
                Navigator.push(
                    context, Utils.createRoute(PdfPage(path: pdfFile.path)));

                return NavigationDecision.prevent;
              } else {
                if (Platform.isAndroid) {
                  scrollStatus = ScrollStatus.forward;
                }
                return NavigationDecision.navigate;
              }
            }
          } else {
            fToast.showToast(
                child: CustomToast(),
                toastDuration: Duration(seconds: 2),
                gravity: ToastGravity.BOTTOM);

            return NavigationDecision.prevent;
          }
        }, onPageStarted: (url) {
          print('onPageStarted');
          sl<BoolCubit>().changeValue(true);
          if (scrollStatus == ScrollStatus.forward) {
            prevPixels.add(
                nestedScrollController.innerScrollController!.position.pixels);
          } else if (scrollStatus == ScrollStatus.prev) {
            oldScroll = prevPixels.last;
            prevPixels.removeLast();
          } else {}
        }, onPageFinished: (url) async {
          print('onPageFinished + $isFirstRun');
          await _webViewController!.runJavaScript(Utils.scrollHeightJs);
          if (scrollStatus == ScrollStatus.forward) {
            if (nestedScrollController.innerScrollController!.offset > 0) {
              nestedScrollController.innerScrollController!.position
                  .setPixels(0);
            }
          } else if (scrollStatus == ScrollStatus.prev) {
            //Timer(Duration(milliseconds: 100), () {
            nestedScrollController.innerScrollController!.position
                .setPixels(oldScroll);

            //});
            //если обновить страницу
          } else {}
          if (Platform.isIOS) {
            scrollStatus = ScrollStatus.forward;
          }

          sl<BoolCubit>().changeValue(false);
        }, onProgress: (progress) {
          print('$progress');
        }, onWebResourceError: (error) {
          if (error.errorType == WebResourceErrorType.hostLookup) {
            print('ошибка интернета нетю: ${error.description}');
          }
        }),
      )
      ..addJavaScriptChannel('ScrollHeightNotifier',
          onMessageReceived: (message) {
        final String msg = message.message;
        final double? height = double.tryParse(msg);
        if (height != null) {
          if (isFirstRun && internetStatus == false) {
            //sl<ScrollHeightCubit>().updateScrollHeight(0);
            //sl<InternetCubit>().changeValue(false);
          } else {
            sl<ScrollHeightCubit>().updateScrollHeight(height);
//скрыть фон при первой загрузке
            if (isBackground) {
              isBackground = false;
            } else {
              if (isFirstRun||isBackgroundNoInternet) {
                sl<BackgroundCubit>().changeValue(false);
                isBackgroundNoInternet=false;
                print('aaa');
              }
            }

            print('onMessageReceived+ $isFirstRun');
          }
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
