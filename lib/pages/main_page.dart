import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_direct_call_plus/flutter_direct_call.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_state.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:kdrc_flutter/widgets/custom_toast.dart';
import 'package:kdrc_flutter/widgets/sliver_webview/sliver_webview.dart';
import 'package:nested_scroll_view_plus/nested_scroll_view_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../cubits/phone_cubit.dart';
import '../locator_service.dart';
import '../main.dart';
import '../utils/utils.dart';

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
    nestedWebviewController = NestedWebviewController(
        /*initialUrl: sl<StartCubit>().state.url,*/ context: context);
    nestedWebviewController!.init();
  }

  @override
  void dispose() {
    sl<InetCubit>().close();
    WidgetsBinding.instance.removeObserver( this );
    super.dispose();
  }


@override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('app resumed');
     check();
    }else if(state == AppLifecycleState.detached){
      print('app detached');
    }else if(state == AppLifecycleState.hidden){
      print('app hidden');
    }else if(state == AppLifecycleState.inactive){
      print('app inactive');
    }else if(state == AppLifecycleState.paused){
      print('app paused');
    }
  }

  void check()async{
    if(callRequestResult){
      final status1 = await Permission.phone.request();
      if(status1.isGranted){
        await FlutterDirectCall.makeDirectCall("+79210779641");
        callRequestResult=false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool canGoBack=await nestedWebviewController!.webViewController!.canGoBack();
        if (canGoBack) {
          nestedWebviewController!.scrollStatus = ScrollStatus.prev;
          nestedWebviewController!.isStep = true;
          nestedWebviewController!.webViewController!.goBack();
          return false;
        } else {
          fToast.showToast(child: CustomToast(message: 'aaa'));
          return false;
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollViewPlus(
            physics: ClampingScrollPhysics(),
            key: nestedWebviewController!.sliverKey1,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                CustomAppBar(
                  nestedWebviewController: nestedWebviewController!,
                ),
              ];
            },
            body: SliverWebview(
              /*  nestedWebviewController: nestedWebviewController!*/),
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
                              Utils.showCallDialog(context);
                              //nestedWebviewController!.webViewController!.reload();
                            });
                      } else {
                        return SizedBox();
                      }
                    });
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
