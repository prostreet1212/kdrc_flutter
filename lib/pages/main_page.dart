import 'dart:developer';
import 'dart:io';

//import 'package:extended_sliver/extended_sliver.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kdrc_flutter/cubits/call_request_is_opened_cubit.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_state.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:kdrc_flutter/widgets/sliver_webview/sliver_webview.dart';
import 'package:nested_scroll_view_plus/nested_scroll_view_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../cubits/phone_cubit.dart';
import '../locator_service.dart';

import '../utils/utils.dart';
import '../widgets/permission_dialog.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.fToast});

  final FToast fToast;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sl<InetCubit>().init();

    sl<NestedWebviewController>().init(widget.fToast, context);

    webViewController = WebViewController()
      ..loadRequest(Uri.parse('https://kdrc.ru/novosti'));
  }

  @override
  void dispose() {
    sl<InetCubit>().close();
    WidgetsBinding.instance.removeObserver(this);
    log('dispose');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      log('app resumed');
      if (sl<NestedWebviewController>().isCrashed == true) {
        log('релоад');
        sl<NestedWebviewController>().scrollStatus = ScrollStatus.reload;
        await sl<NestedWebviewController>().webViewController.reload();
        sl<NestedWebviewController>().isStep = true;
        sl<NestedWebviewController>().isCrashed = false;
      }
      checkCallStatus();
    } else if (state == AppLifecycleState.detached) {
      log('app detached');
    } else if (state == AppLifecycleState.hidden) {
      log('app hidden');
    } else if (state == AppLifecycleState.inactive) {
      log('app inactive');
    } else if (state == AppLifecycleState.paused) {
      log('app paused');
    }
  }

  void checkCallStatus() async {
    if (context.read<CallRequestIsOpenedCubit>().state) {
      final status1 = await Permission.phone.status;
      if (status1.isGranted) {
        if (mounted) {
          Utils.showCallDialog(context);
        }
        if (!mounted) return;
        context.read<CallRequestIsOpenedCubit>().changeValue(false);
      }
    }
  }

  InAppWebViewController? inAppWebViewController = null;

  @override
  Widget build(BuildContext context3) {
    log('build mainpage');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        bool canGoBack = await sl<NestedWebviewController>().webViewController
            .canGoBack();
        if (canGoBack) {
          sl<NestedWebviewController>().scrollStatus = ScrollStatus.prev;
          sl<NestedWebviewController>().isStep = true;
          sl<NestedWebviewController>().webViewController.goBack();
        } else {
          //await SystemNavigator.pop();
          await FlutterExitApp.exitApp();
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: NestedScrollView(
            headerSliverBuilder: (c, b) {
              return [
                SliverPadding(
                  padding: EdgeInsets.all(0),
                  sliver: SliverAppBar(
                    expandedHeight: 210,
                    collapsedHeight: 56,
                    pinned: true,
                  ),
                ),
              ];
            },
            body: /*CustomScrollView(
              physics: RangeMaintainingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SizedBox(
                    height: 1491,
                    child:WebViewWidget(controller: WebViewController()..loadRequest(Uri.parse('https://kdrc.ru/novosti')))
                    /*InAppWebView(
                      onWebViewCreated: (c) {
                        inAppWebViewController = c;
                      },
                      initialUrlRequest: URLRequest(
                        url: WebUri('https://kdrc.ru/novosti'),
                      ),
                      initialSettings: InAppWebViewSettings(
                        //contentInsetAdjustmentBehavior: ScrollViewContentInsetAdjustmentBehavior.ALWAYS
                        overScrollMode: OverScrollMode.ALWAYS,
                        scrollsToTop: true,
                      ),
                    ),*/
                  ),*/ CustomScrollView(
              // cacheExtent: 1000,
              // physics: ScrollPhysics(),
              //physics: FixedExtentScrollPhysics(),
              //physics: CarouselScrollPhysics(),
              //  physics: NeverScrollableScrollPhysics(),
              //physics: BouncingScrollPhysics(),
              //scrollBehavior: ScrollBehavior(),
              physics: ClampingScrollPhysics(),
              primary: true,
              // hitTestBehavior: HitTestBehavior.translucent,
              slivers: [
                SliverToNestedScrollBoxAdapter(
                  childExtent: 1491,
                  onScrollOffsetChanged: (scrollOffset) {
                    double y = scrollOffset;
                    if (Platform.isAndroid) {
                      y *= View.of(context).devicePixelRatio;
                      //y*=2.55;
                    }
                    if (inAppWebViewController != null) {
                      inAppWebViewController!.scrollTo(x: 0, y: y.ceil());
                    }

                    //webViewController.scrollTo(0, y.ceil());
                  },
                  child: //WebViewWidget(controller: webViewController),
                  InAppWebView(
                    onWebViewCreated: (c) {
                      inAppWebViewController = c;
                    },
                    initialUrlRequest: URLRequest(
                      url: WebUri('https://kdrc.ru/novosti'),
                    ),
                    initialSettings: InAppWebViewSettings(),
                  ),
                ),
              ],
            ),
          ),
          /*NestedScrollView(
            controller: sl<NestedWebviewController>().nestedScrollController,
            //physics: AlwaysScrollableScrollPhysics(),
            //physics: ClampingScrollPhysics(),
            headerSliverBuilder: (
              BuildContext context,
              bool innerBoxIsScrolled,
            ) {
              return [
                 CustomAppBar(
                  fToast: widget.fToast,
                ),
              ];
            },
            body: SliverWebview(
              fToast: widget.fToast,
              ),
          ),*/
          floatingActionButton: BlocBuilder<PhoneCubit, bool>(
            builder: (context, phoneState) {
              if (phoneState) {
                return BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context1, state) {
                    if (state.isCalling) {
                      return FloatingActionButton(
                        backgroundColor: Colors.grey[50],
                        shape: const CircleBorder(),
                        child: Icon(
                          Icons.call,
                          color: Color.fromARGB(255, 247, 176, 116),
                          size: 36,
                        ),
                        onPressed: () async {
                          PermissionStatus status =
                              await Permission.phone.status;

                          if (status.isGranted) {
                            if (context.mounted) {
                              Utils.showCallDialog(context);
                            }
                          } else if (status.isPermanentlyDenied) {
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return PermissionDialog();
                                },
                              );
                            }
                            //openAppSettings();
                          } else if (status.isDenied) {
                            final status1 = await Permission.phone.request();
                            if (status1.isGranted) {
                              if (context.mounted) {
                                Utils.showCallDialog(context);
                              }
                            }
                          } else {
                            log("Permission denied");
                          }
                        },
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }
}

class PlatformViewVerticalGestureRecognizer
    extends VerticalDragGestureRecognizer {
  PlatformViewVerticalGestureRecognizer({PointerDeviceKind? kind})
    : super(supportedDevices: <PointerDeviceKind>{kind!});

  Offset _dragDistance = Offset.zero;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    _dragDistance = _dragDistance + event.delta;
    if (event is PointerMoveEvent) {
      final double dy = _dragDistance.dy.abs();
      final double dx = _dragDistance.dx.abs();

      if (dy > dx && dy > kTouchSlop) {
        // vertical drag - accept
        resolve(GestureDisposition.accepted);
        _dragDistance = Offset.zero;
      } else if (dx > kTouchSlop && dx > dy) {
        // horizontal drag - stop tracking
        stopTrackingPointer(event.pointer);
        _dragDistance = Offset.zero;
      }
    }
  }

  @override
  String get debugDescription => 'horizontal drag (platform view)';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
