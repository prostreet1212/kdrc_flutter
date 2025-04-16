import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_state.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:kdrc_flutter/widgets/custom_toast.dart';
import 'package:kdrc_flutter/widgets/sliver_webview/sliver_webview.dart';
import 'package:nested_scroll_view_plus/nested_scroll_view_plus.dart';
import '../cubits/phone_cubit.dart';
import '../locator_service.dart';
import '../main.dart';
import '../utils/utils.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    sl<InetCubit>().init();
    nestedWebviewController = NestedWebviewController(
        /*initialUrl: sl<StartCubit>().state.url,*/ context: context);
    nestedWebviewController!.init();
  }

  @override
  void dispose() {
    sl<InetCubit>().close();
    // nestedWebviewController!.internetListener.cancel();
    super.dispose();
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
                    builder: (context, state) {
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
