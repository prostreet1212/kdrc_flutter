import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kdrc_flutter/cubits/call_request_is_opened_cubit.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/widgets/call_button.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:kdrc_flutter/widgets/sliver_webview/sliver_webview.dart';
import 'package:permission_handler/permission_handler.dart';
import '../cubits/loading_cubit.dart';
import '../locator_service.dart';

import '../utils/utils.dart';
import '../widgets/go_back_button.dart';


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
      //если webview крашнулось перезагружаем страницу
      if (sl<NestedWebviewController>().isCrashed == true) {
        print('релоад');
        //sl<NestedWebviewController>().scrollStatus = ScrollStatus.reload;
        await sl<NestedWebviewController>().webViewController!.reload();
        sl<NestedWebviewController>().isStep = true;
        sl<NestedWebviewController>().isCrashed = false;
      }
      //проверка нужно ли звонить
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
    if (sl<CallRequestIsOpenedCubit>().state) {
      if (Platform.isIOS) {
        final status1 = await Permission.contacts.status;
        if (status1.isGranted) {
          if (mounted) {
            Utils.showCallDialog(context);
          }
          //await FlutterPhoneDirectCaller.callNumber('79532602744');
        }
      } else {
        final status1 = await Permission.phone.status;
        if (status1.isGranted) {
          if (mounted) {
            Utils.showCallDialog(context);
          }
          //if (!mounted) return;
          //context.read<CallRequestIsOpenedCubit>().changeValue(false);
        }
      }
      sl<CallRequestIsOpenedCubit>().changeValue(false);
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
        //устанавливаем значение cancel при переоде назад на случай если был совершен переод назад без интернета а затем переодя вперед
        if(Platform.isAndroid){
          sl<NestedWebviewController>().
          navigationDecision = NavigationActionPolicy.CANCEL;
        }
        if (canGoBack) {
          sl<LoadingCubit>().changeValue(true);
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
            //physics: const BouncingScrollPhysics(),
            //floatHeaderSlivers: true, //
            controller: sl<NestedWebviewController>().nestedScrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
                  return [const CustomAppBar()];
                },
            body: const SliverWebview(),
          ),
          floatingActionButton:  const Row(
            //mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [GoBackButton(),
              CallButton(),
              /*FloatingActionButton(onPressed: (){
                sl<NestedWebviewController>().webViewController!.loadUrl( urlRequest: URLRequest(url: WebUri('https://kdrc.ru/novosti')));
              })*/],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniEndFloat,
        ),
      ),
    );
  }
}

/*class MySliverPinnedPersistentHeaderDelegate
    extends SliverPinnedPersistentHeaderDelegate {
  MySliverPinnedPersistentHeaderDelegate({
    required Widget minExtentProtoType,
    required Widget maxExtentProtoType,
  }) : super(
         minExtentProtoType: minExtentProtoType,
         maxExtentProtoType: maxExtentProtoType,
       );

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    double? minExtent,
    double maxExtent,
    bool overlapsContent,
  ) {
    print(shrinkOffset);
    return Stack(
      children: <Widget>[
        Positioned(
          child: maxExtentProtoType,
          top: -shrinkOffset,
          bottom: 0,
          left: 0,
          right: 0,
        ),
        Positioned(child: minExtentProtoType, top: 0, left: 0, right: 0),
      ],
    );
  }

  @override
  bool shouldRebuild(SliverPinnedPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
*/