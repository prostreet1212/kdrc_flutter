import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/cubits/is_collapsed_cubit.dart';
import 'package:kdrc_flutter/utils/utils.dart';
import 'package:kdrc_flutter/widgets/file_loading_dialog.dart';

import 'package:nested_scroll_view_plus/nested_scroll_view_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../cubits/background_cubit.dart';
import '../cubits/error_text_cubit.dart';
import '../cubits/inet_cubit.dart';
import '../cubits/scroll_height_cubit.dart';
import '../cubits/start_cubit/start_cubit.dart';
import '../locator_service.dart';
import '../main.dart';
import '../pages/pdf_page.dart';
import '../widgets/custom_toast.dart';

enum ScrollStatus { prev, forward, reload }

class NestedWebviewController {
  NestedWebviewController({required this.context});

  BuildContext context;
  WebViewController? _webViewController;
  WebViewController? get webViewController => _webViewController;
  ScrollStatus scrollStatus = ScrollStatus.forward;
  double oldScroll = 0.0;

  List<double> prevPixels = [];
  bool isStep = false;

  //bool internetStatus = true;
  bool isFirstRun = true;
  //bool isBackground = true;
  //bool isBackgroundNoInternet = true;



  // late StreamSubscription<InternetStatus> internetListener;
  static var httpClient = new HttpClient();
  final GlobalKey<NestedScrollViewStatePlus> sliverKey1 = GlobalKey();

  Future<File?> _downloadFile(String url, String filename) async {
    try {
      var request = await httpClient.getUrl(Uri.parse('${url}'));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = new File('$dir/$filename');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      Navigator.pop(context);
      fToast.showToast(
          child: CustomToast(
            message:
                'Не удалось открыть файл. Проверьте подключение к сети интернет',
          ),
          toastDuration: Duration(seconds: 3),
          gravity: ToastGravity.BOTTOM);
      return null;
      //throw Exception(e);
    }
  }

  Future<bool> canGoBack() async {
    return await _webViewController!.canGoBack();
  }

  void init() {
    fToast.init(context);
    _webViewController = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
            onNavigationRequest: (request) async {
          print('onPageSRequest');
          if (/*internetStatus*/sl<InetCubit>().state==true) {
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
                File? pdfFile = await _downloadFile(
                    request.url, 'file.${Utils.getTypeFile(request.url)}');
                if (pdfFile != null) {
                  Navigator.pop(context);
                  OpenFilex.open(pdfFile!.path);
                }
                return NavigationDecision.prevent;
              } else if (request.url.contains('.pdf')) {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return FileLoadingDialog();
                    });
                File? pdfFile = await _downloadFile(
                    request.url, 'file.${Utils.getTypeFile(request.url)}');
                if (pdfFile != null) {
                  Navigator.pop(context);
                  Navigator.push(
                      context, Utils.createRoute(PdfPage(path: pdfFile!.path)));
                }
                return NavigationDecision.prevent;
              } else {
                if (Platform.isAndroid) {
                  scrollStatus = ScrollStatus.forward;
                  nestedWebviewController!.isStep = true;
                }
                return NavigationDecision.navigate;
              }
            }
          } else {
            fToast.showToast(
                child: CustomToast(
                  message: 'Проверьте подключение к сети интернет',
                ),
                toastDuration: Duration(seconds: 2),
                gravity: ToastGravity.BOTTOM);

            return NavigationDecision.prevent;
          }
        },
            onPageStarted: (url) {
          print('onPageStarted');
          sl<BoolCubit>().changeValue(true);
          if (scrollStatus == ScrollStatus.forward) {
            prevPixels
                .add(sliverKey1.currentState!.innerController.position.pixels);
          } else if (scrollStatus == ScrollStatus.prev) {
            oldScroll = prevPixels.last;
            prevPixels.removeLast();
          } else {}
        }
        , onPageFinished: (url) async {
          print('onPageFinished + $isFirstRun');
          await _webViewController!.runJavaScript(Utils.scrollHeightJs);
          //здесь были смещения
          ///
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
          onMessageReceived: (message) async {
        final String msg = message.message;
        final double? height = double.tryParse(msg);
        if (height != null) {
          if (isFirstRun &&/* internetStatus == false*/sl<InetCubit>().state==false) {
            sl<ErrorTextCubit>().changeValue(false);
          } else {
            sl<ScrollHeightCubit>().updateScrollHeight(height);


//скрыть фон при первой загрузке
            if (sl<BackgroundCubit>().state==true/*isBackground*/) {
              //isBackground = false;
              sl<BackgroundCubit>().changeValue(false);
              //доп
              //isFirstRun=false;
            } else {
              if (isFirstRun||sl<BackgroundCubit>().state==true /*|| isBackgroundNoInternet*/) {
                sl<BackgroundCubit>().changeValue(false);
                //доп
                //isFirstRun=false;

                //isBackgroundNoInternet = false;
                print('aaa');
              }
            }

            print('onMessageReceived+ $isFirstRun');
          }
        }
      })
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(sl<StartCubit>().state.url),
      )
      ..setBackgroundColor(Colors.transparent);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      sliverKey1.currentState!.outerController.addListener(() {
        if (sliverKey1.currentState!.outerController.offset > 112) {
          if (sl<IsCollapsedCubit>().state != true) {
            sl<IsCollapsedCubit>().updateIsCollapsed(true);
          }
        } else {
          if (sl<IsCollapsedCubit>().state != false) {
            sl<IsCollapsedCubit>().updateIsCollapsed(false);
          }
        }
      });
    });
  }
}
