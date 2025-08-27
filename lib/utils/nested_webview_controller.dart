import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:kdrc_flutter/cubits/loading_cubit.dart';
import 'package:kdrc_flutter/utils/utils.dart';
import 'package:kdrc_flutter/widgets/file_loading_dialog.dart';
import 'package:nested_scroll_controller/nested_scroll_controller.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubits/background_cubit.dart';
import '../cubits/error_text_cubit.dart';
import '../cubits/inet_cubit.dart';
import '../cubits/is_collapsed_cubit.dart';
import '../cubits/scroll_height_cubit.dart';
import '../locator_service.dart';
import '../pages/pdf_page.dart';
import '../widgets/custom_toast.dart';

enum ScrollStatus { prev, forward, reload }

class NestedWebviewController {
  NestedWebviewController();

  InAppWebViewController? webViewController;
  final Completer<InAppWebViewController> controllerCompleter = Completer();


  ScrollStatus scrollStatus = ScrollStatus.forward;
  double oldScroll = 0.0;

  List<double> prevPixels = [];
  bool isStep = false;

  bool isFirstRun = true;
  NavigationActionPolicy navigationDecision = NavigationActionPolicy.ALLOW;
  bool loadError = false;

  static var httpClient = HttpClient();
  double currentInnerPixel = 0;
  bool isCrashed = false;

  final FToast fToast = FToast();

  //доступ к внутреннему контроллеру-альтернатива
  //final GlobalKey<NestedScrollViewStatePlus> sliverKey1 = GlobalKey();
  final NestedScrollController nestedScrollController = NestedScrollController(
    keepScrollOffset: false,
  );

  Future<File?> _downloadFile(
    String url,
    String filename,
    FToast fToast,
    BuildContext context,
  ) async {
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = File('$dir/$filename');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
      }
      fToast.showToast(
        child: const CustomToast(
          message:
              'Не удалось открыть файл. Проверьте подключение к сети интернет',
        ),
        toastDuration: const Duration(seconds: 3),
        gravity: ToastGravity.BOTTOM,
      );
      return null;
      //throw Exception(e);
    }
  }

  void init(BuildContext context) async {
    fToast.init(context);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      nestedScrollController.addListener(() {
        currentInnerPixel =
            nestedScrollController.innerScrollController!.position.pixels;
        double outerPixel = nestedScrollController.position.pixels;

        log('inner pixels: $currentInnerPixel');
        log('outer pixels: $outerPixel');
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
    });
  }

  void onWebViewCreated(InAppWebViewController c) {
    webViewController = c;
    controllerCompleter.complete(c);
    webViewController!.addJavaScriptHandler(
      handlerName: 'onContentHeightChanged',
      callback: (args) {
        final double? height = double.tryParse(args[0]);
        log('Высота контента: $height');

        if (height != null) {
          if (isFirstRun && sl<InetCubit>().state == false) {
            sl<ErrorTextCubit>().changeValue(false);
          } else {
            if (loadError == true) {
              loadError = false;
            } else {
              isFirstRun = false;
              loadError = false;
            }
            //скрыть фон при первой загрузке
            if (sl<BackgroundCubit>().state == true /*isBackground*/ ) {
              sl<BackgroundCubit>().changeValue(false);
            } else {
              if (isFirstRun ||
                  sl<BackgroundCubit>().state ==
                      true /*|| isBackgroundNoInternet*/ ) {
                sl<BackgroundCubit>().changeValue(false);
                log('aaa');
              }
            }
            log('onMessageReceived+ $isFirstRun');
            sl<ScrollHeightCubit>().updateScrollHeight(height);
          }
        }
      },
    );
  }

  void onLoadStart(InAppWebViewController c, WebUri? uri) {
    log('onPageStarted');
    //sl<BoolCubit>().changeValue(true);
    if (scrollStatus == ScrollStatus.forward) {
      prevPixels.add(
        nestedScrollController
            .innerScrollController!
            .position
            .pixels /*sliverKey1.currentState!.innerController.position.pixels*/,
      );
    } else if (scrollStatus == ScrollStatus.prev) {
      oldScroll = prevPixels.last;
      prevPixels.removeLast();
    } else {}
  }

  Future<void> onLoadStop(InAppWebViewController c, WebUri? uri) async {
    log('onPageFinished + $isFirstRun');
    await webViewController!.evaluateJavascript(source: Utils.scrollHeightJs);
    //здесь были смещения
    ///???
    /* if (Platform.isIOS) {
      scrollStatus = ScrollStatus.forward;
    }*/
    sl<LoadingCubit>().changeValue(false);
  }

  void onProgressChanged(InAppWebViewController c, int progress) {
    log('$progress');
  }

  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
    InAppWebViewController c,
    NavigationAction navigationAction,
    FToast fToast,
    BuildContext context,
  ) async {
    log('onPageSRequest');
    //return NavigationActionPolicy.ALLOW;
    if (sl<InetCubit>().state == true) {
      log('url1 ${navigationAction.request.url.toString()}');
      if (!navigationAction.request.url.toString().contains('kdrc.ru') ||
          navigationAction.request.url.toString().contains('mailto:')) {
        if (navigationAction.request.url.toString().contains('vkvideo.ru') ||
            navigationAction.request.url.toString().contains(
              'vk.com/video_ext',
            ) ||
            navigationAction.request.url.toString().contains('yandex.ru') ||
            navigationAction.request.url.toString().contains('youtube.com') ||
            navigationAction.request.url.toString().contains('about:blank')) {
          return NavigationActionPolicy.ALLOW;
        } else {
          //для вк приложения
          if (navigationAction.request.url.toString().contains('vk.com/club')) {
            final uri = navigationAction.request.url;
            final vkAppUrl = Uri.parse(
              'vk://vk.com${uri!.path}?event=openExternal',
            );
            if (await canLaunchUrl(vkAppUrl)) {
              await launchUrl(vkAppUrl, mode: LaunchMode.externalApplication);
            } else {
              launchUrl(Uri.parse(navigationAction.request.url.toString()));
            }
          } else {
            launchUrl(Uri.parse(navigationAction.request.url.toString()));
          }

          return NavigationActionPolicy.CANCEL;
        }
      } else {
        if (navigationAction.request.url.toString().contains('.doc') ||
            navigationAction.request.url.toString().contains('.xls')) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const FileLoadingDialog();
            },
          );
          var typeFile = Utils.getTypeFile(
            navigationAction.request.url.toString(),
          );
          File? pdfFile = await _downloadFile(
            navigationAction.request.url.toString(),
            'file.$typeFile',
            fToast,
            context,
          );
          if (pdfFile != null) {
            OpenResult openResult = await OpenFilex.open(
              pdfFile.path,
              //type: 'application/msword',
            );
            if (openResult.type != ResultType.done) {
              /* fToast.showToast(
                child: CustomToast(message: 'Не удалось открыть файл. Для просмотра документа установите приложение, формата .$typeFile'),
                toastDuration: Duration(seconds: 3),
                gravity: ToastGravity.BOTTOM,
              );*/
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Не удалось открыть документ. Установите приложение, для просмотра документов в формате $typeFile',
                    ),
                    duration: const Duration(milliseconds: 3500),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'ОК',
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      textColor: const Color.fromARGB(255, 247, 176, 116),
                    ),
                  ),
                );
              }
            }
            log('openx ${openResult.message}');
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
          return NavigationActionPolicy.CANCEL;
        } else if (navigationAction.request.url.toString().contains('.pdf')) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const FileLoadingDialog();
            },
          );
          File? pdfFile = await _downloadFile(
            navigationAction.request.url.toString(),
            'file.${Utils.getTypeFile(navigationAction.request.url.toString())}',
            fToast,
            context,
          );
          if (pdfFile != null) {
            if (context.mounted) {
              Navigator.pop(context);
              Navigator.push(
                context,
                Utils.createRoute(PdfPage(path: pdfFile.path)),
              );
            }
          }
          return NavigationActionPolicy.CANCEL;
        } else {
          sl<LoadingCubit>().changeValue(true);
          if (Platform.isAndroid) {
            scrollStatus = ScrollStatus.forward;
            //isStep = true;
          }

          isStep = true;

          navigationDecision = NavigationActionPolicy.ALLOW;
          return navigationDecision;
        }
      }
    } else {
      //вывод сообщения при непервом запуске и навигации вперед
      //исправить
      if (Platform.isAndroid) {
        scrollStatus = ScrollStatus.forward;
      }
      if (isFirstRun == false&&
          scrollStatus== ScrollStatus.forward) {
        fToast.showToast(
          child: const CustomToast(
            message: 'Проверьте подключение к сети интернет',
          ),
          toastDuration: const Duration(seconds: 2),
          gravity: ToastGravity.BOTTOM,
        );
      }
      //разрешить навигацию назад в ios когда нет интернета
      if (Platform.isIOS &&
          scrollStatus == ScrollStatus.prev) {
        navigationDecision = NavigationActionPolicy.ALLOW;
      } else {
        navigationDecision = NavigationActionPolicy.CANCEL;
      }
      return navigationDecision;
    }
  }

  Future<void> onReceivedError(WebResourceError error) async {
    print('onReceivedError');
    if (error.type == WebResourceErrorType.HOST_LOOKUP) {
      log('ошибка интернета нетю: ${error.description}');
      if (navigationDecision == NavigationActionPolicy.ALLOW) {
        isFirstRun = true;
        loadError = true;
        log('onPageErrorNavigate');
      } else {
        log('onPageErrorPrev');
      }
    }


//ios не смог загрузить страницу и выдал сообщение
    if(Platform.isIOS&&(error.type==WebResourceErrorType.NOT_CONNECTED_TO_INTERNET||error.type==WebResourceErrorType.CANCELLED)&&isFirstRun == false){
      //webViewController!.stopLoading();
      sl<LoadingCubit>().changeValue(false);
      fToast.showToast(
        child: const CustomToast(
          message: 'Проверьте подключение к сети интернет',
        ),
        toastDuration: const Duration(seconds: 2),
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}

/*

class NestedWebviewController111 {
  NestedWebviewController();



  late WebViewController webViewController;

  ScrollStatus scrollStatus = ScrollStatus.forward;
  double oldScroll = 0.0;

  List<double> prevPixels = [];
  bool isStep = false;

  bool isFirstRun = true;
  NavigationDecision navigationDecision=NavigationDecision.navigate;
  bool loadError = false;

  static var httpClient =  HttpClient();
  //доступ к внутреннему контроллеру-альтернатива
  //final GlobalKey<NestedScrollViewStatePlus> sliverKey1 = GlobalKey();
  final NestedScrollController nestedScrollController = NestedScrollController();

  Future<File?> _downloadFile(String url, String filename,FToast fToast, BuildContext context) async {
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file =  File('$dir/$filename');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      if(context.mounted){
        Navigator.pop(context);
      }
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
    return await webViewController!.canGoBack();
  }

  void init(FToast fToast,BuildContext context)async {
    fToast.init(context);
    webViewController = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
            onNavigationRequest: (request) async {
          print('onPageSRequest');
          if (sl<InetCubit>().state==true) {
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
                    request.url, 'file.${Utils.getTypeFile(request.url)}',fToast,context);
                if (pdfFile != null) {
                    OpenFilex.open(pdfFile.path);
                    if(context.mounted){
                    Navigator.pop(context);
                  }

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
                    request.url, 'file.${Utils.getTypeFile(request.url)}',fToast,context);
                if (pdfFile != null) {
                  if(context.mounted){
                    Navigator.pop(context);
                    Navigator.push(
                        context, Utils.createRoute(PdfPage(path: pdfFile.path)));
                  }

                }
                return NavigationDecision.prevent;
              } else {
                if (Platform.isAndroid) {
                  scrollStatus = ScrollStatus.forward;
                  isStep = true;
                }
                navigationDecision=NavigationDecision.navigate;
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
            navigationDecision=NavigationDecision.prevent;
            return NavigationDecision.prevent;
          }
        },
            onPageStarted: (url) {
          print('onPageStarted');
          sl<BoolCubit>().changeValue(true);
          if (scrollStatus == ScrollStatus.forward) {
            prevPixels
                .add(nestedScrollController.innerScrollController!.position.pixels/*sliverKey1.currentState!.innerController.position.pixels*/);
          } else if (scrollStatus == ScrollStatus.prev) {
            oldScroll = prevPixels.last;
            prevPixels.removeLast();
          } else {}
        }
        , onPageFinished: (url) async {
          print('onPageFinished + $isFirstRun');
          await webViewController!.runJavaScript(Utils.scrollHeightJs);
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
            if(navigationDecision==NavigationDecision.navigate){
              isFirstRun=true;
              loadError=true;
              print('onPageErrorNaigate');
            }else{
              print('onPageErrorPrev');
            }
          }
        },),
      )
      ..addJavaScriptChannel('ScrollHeightNotifier',
          onMessageReceived: (message) async {
        final String msg = message.message;
        final double? height = double.tryParse(msg);
        if (height != null) {
          if (isFirstRun &&sl<InetCubit>().state==false) {
            sl<ErrorTextCubit>().changeValue(false);
          } else {

              if(loadError ==true ){
                loadError =false;
              }else{
                isFirstRun=false;
                loadError =false;
              }
//скрыть фон при первой загрузке
              if (sl<BackgroundCubit>().state==true/*isBackground*/) {
                sl<BackgroundCubit>().changeValue(false);
              } else {
                if (isFirstRun||sl<BackgroundCubit>().state==true /*|| isBackgroundNoInternet*/) {
                  sl<BackgroundCubit>().changeValue(false);
                  print('aaa');
                }
              }
              print('onMessageReceived+ $isFirstRun');
            sl<ScrollHeightCubit>().updateScrollHeight(height);
          }
        }
      })
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
     // ..setBackgroundColor(Color.fromARGB(255, 255, 247, 255));
      ..setBackgroundColor(Colors.white);
       await webViewController.loadRequest(
        Uri.parse(sl<StartCubit>().state.url),
      );

       webViewController.setOnConsoleMessage((m){
         print('aaa ${m.message}');
       });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

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
    });
  }
}*/
