import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:kdrc_flutter/cubits/call_request_is_opened_cubit.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_state.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:kdrc_flutter/widgets/sliver_webview/sliver_webview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../cubits/phone_cubit.dart';
import '../locator_service.dart';



import '../utils/utils.dart';
import '../widgets/permission_dialog.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sl<InetCubit>().init();

    sl<NestedWebviewController>().init(context);
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
        await sl<NestedWebviewController>().webViewController!.reload();
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

  InAppWebViewController? inAppWebViewController;

  @override
  Widget build(BuildContext context3) {
    log('build mainpage');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        bool canGoBack = await sl<NestedWebviewController>().webViewController!
            .canGoBack();
        if (canGoBack) {
          sl<NestedWebviewController>().scrollStatus = ScrollStatus.prev;
          sl<NestedWebviewController>().isStep = true;
          sl<NestedWebviewController>().webViewController!.goBack();
        } else {
          //await SystemNavigator.pop();
          await FlutterExitApp.exitApp();
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: NestedScrollView(
            controller: sl<NestedWebviewController>().nestedScrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    const CustomAppBar(),
                  ];
                },
            body: const SliverWebview(
              ),
          ),
          floatingActionButton: BlocBuilder<PhoneCubit, bool>(
            builder: (context, phoneState) {
              if (phoneState) {
                return BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context1, state) {
                    if (state.isCalling) {
                      return PointerInterceptor(
                        intercepting: true,
                        child: FloatingActionButton(
                          backgroundColor: Colors.grey[50],
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.call,
                            color: Color.fromARGB(255, 247, 176, 116),
                            size: 36,
                          ),
                          onPressed: () async {
                            if (Platform.isIOS) {
                              final status = await Permission.contacts
                                  .request();
                              if (status != PermissionStatus.granted) {
                                return;
                              }
                              bool? res =
                                  await FlutterPhoneDirectCaller.callNumber(
                                    '79532602744',
                                  );
                              /*final Uri phoneUri = Uri(scheme: 'tel', path: '79210779641');
                              if (await canLaunchUrl(phoneUri)) {
                                await launchUrl(phoneUri);
                              } else {
                                throw 'Не удалось выполнить звонок на номер 79210779641';
                              }*/
                            } else {
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
                                      return const PermissionDialog();
                                    },
                                  );
                                }
                                //openAppSettings();
                              } else if (status.isDenied) {
                                final status1 = await Permission.phone
                                    .request();
                                if (status1.isGranted) {
                                  if (context.mounted) {
                                    Utils.showCallDialog(context);
                                  }
                                }
                              } else {
                                log("Permission denied");
                              }
                            }
                          },
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }
}
