
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_direct_call_plus/flutter_direct_call.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_state.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:kdrc_flutter/widgets/sliver_webview/sliver_webview.dart';
import 'package:permission_handler/permission_handler.dart';
import '../cubits/phone_cubit.dart';
import '../locator_service.dart';
import '../utils/utils.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.fToast,
    required this.callRequestResult,
  });

  final FToast fToast;
  final bool callRequestResult;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sl<InetCubit>().init();

    /*   widget.nestedWebviewController = NestedWebviewController(
        context: context,fToast: widget.fToast);
    //widget.nestedWebviewController!.init();*/
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
      check();
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

  void check() async {
    if (widget.callRequestResult) {
      final status1 = await Permission.phone.request();
      if (status1.isGranted) {
        await FlutterDirectCall.makeDirectCall("+79210779641");
        widget.callRequestResult != false;
      }
    }
  }

  @override
  Widget build(BuildContext context3) {
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
     /* onWillPop: () async {
        bool canGoBack =
            await sl<NestedWebviewController>().webViewController.canGoBack();
        if (canGoBack) {
          sl<NestedWebviewController>().scrollStatus = ScrollStatus.prev;
          sl<NestedWebviewController>().isStep = true;
          sl<NestedWebviewController>().webViewController.goBack();
          return false;
        } else {
          return true;
          //await SystemNavigator.pop();
          //await FlutterExitApp.exitApp();
        }
      },*/
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
                          Utils.showCallDialog(
                            context,
                            widget.callRequestResult,
                          );

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
