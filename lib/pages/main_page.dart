
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kdrc_flutter/cubits/call_request_is_opened_cubit.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/scroll_height_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_state.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:kdrc_flutter/widgets/sliver_webview/sliver_webview.dart';
import 'package:permission_handler/permission_handler.dart';
import '../cubits/phone_cubit.dart';
import '../locator_service.dart';

import '../utils/utils.dart';
import '../widgets/permission_dialog.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.fToast,
  });

  final FToast fToast;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sl<InetCubit>().init();

    sl<NestedWebviewController>().init(widget.fToast, context);
  }

  @override
  void dispose() {
    sl<InetCubit>().close();
    WidgetsBinding.instance.removeObserver(this);
    print('dispose');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('app resumed');
      if(sl<NestedWebviewController>().isCrashed==true){
        print('релоад');
        sl<NestedWebviewController>().scrollStatus =
            ScrollStatus.reload;
        await sl<NestedWebviewController>().webViewController.reload();
        sl<NestedWebviewController>().isStep=true;
            sl<NestedWebviewController>().isCrashed=false;
      }
      checkCallStatus();
    } else if (state == AppLifecycleState.detached) {
      print('app detached');
    } else if (state == AppLifecycleState.hidden) {
      print('app hidden');
    } else if (state == AppLifecycleState.inactive) {
      print('app inactive');
    } else if (state == AppLifecycleState.paused) {
      print('app paused');
    }
  }

  void checkCallStatus() async {
    if (context.read<CallRequestIsOpenedCubit>().state) {
      final status1 = await Permission.phone.status;
      if (status1.isGranted) {
        Utils.showCallDialog(
            context
        );
          if (!mounted) return;
          context.read<CallRequestIsOpenedCubit>().changeValue(false);
      }
    }
  }

  @override
  Widget build(BuildContext context3) {
    print('build mainpage');
    return PopScope(
       canPop: false,
     onPopInvokedWithResult: ( didPop,  result)async{
       if (didPop) {
         return;
       }
       bool canGoBack=await sl<NestedWebviewController>().webViewController.canGoBack();
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
            controller: sl<NestedWebviewController>().nestedScrollController,
            physics: ClampingScrollPhysics(),
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
          ),
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

                          //await sl<NestedWebviewController>().webViewController.reload();
                    /*  print('${sl<NestedWebviewController>()
                          .scrollStatus}');*/

                          PermissionStatus status = await Permission.phone.status;
                          if (status.isGranted) {
                            Utils.showCallDialog(
                            context
                          );
                          }else if (status.isPermanentlyDenied) {
                            //await Permission.phone.request();
                            if(context.mounted) {
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    //Navigator.pop(context);
                                    return PermissionDialog();
                                  });
                            }
                            //openAppSettings();
                          } else if (status.isDenied) {
                            final status1 = await Permission.phone.request();
                            if(status1.isGranted){
                              Utils.showCallDialog(
                                  context
                              );
                            }
                          } else {
                            print("Permission denied");
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
