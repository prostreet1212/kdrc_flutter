import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intrinsic_size_builder/intrinsic_size_builder.dart';
import 'package:kdrc_flutter/cubits/background_cubit.dart';
import 'package:kdrc_flutter/cubits/error_text_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit.dart';
import 'package:kdrc_flutter/cubits/start_cubit/start_cubit.dart';

import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:kdrc_flutter/widgets/custom_toast.dart';

import 'package:kdrc_flutter/widgets/sliver_webview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubits/phone_cubit.dart';
import '../cubits/scroll_height_cubit.dart';
import '../locator_service.dart';
import '../main.dart';
import '../utils/utils.dart';
bool aaa=false;
class SlWebCopy extends StatefulWidget {
  const SlWebCopy({super.key});

  @override
  State<SlWebCopy> createState() => _SlWebCopyState();
}

class _SlWebCopyState extends State<SlWebCopy> {


  @override
  void initState() {
    super.initState();
   nestedWebviewController = NestedWebviewController(
        initialUrl: sl<StartCubit>().state.url, context: context);
    nestedWebviewController!.init();


  }


  @override
  void dispose() {
   // nestedWebviewController!.internetListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await nestedWebviewController!.webViewController!.canGoBack()) {
          nestedWebviewController!.scrollStatus = ScrollStatus.prev;
          nestedWebviewController!.webViewController!.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollView(
            key: key,
           // controller: nestedWebviewController!.nestedScrollController,
            controller: nestedWebviewController!.nestedScrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [

               CustomAppBar(
                  nestedWebviewController: nestedWebviewController!,
                ),
              ];
            },
            body: SliverWebview(nestedWebviewController: nestedWebviewController!),

          ),
          floatingActionButton: BlocBuilder<PhoneCubit,bool>(
            builder: (context, phoneState) {
              if(phoneState){
                return   BlocProvider<SettingsCubit>(
                    create: (c) => sl<SettingsCubit>()..getCalling(),
                    child: BlocBuilder<SettingsCubit, bool>(builder: (context, state) {
                      if (state) {
                        return FloatingActionButton(
                            backgroundColor: Colors.grey[50],
                            shape: const CircleBorder(),
                            child: Icon(
                              Icons.call,
                              color: Color.fromARGB(255, 247, 176, 116),
                              size: 36,
                            ),
                            onPressed: () async {
                              //key.currentState!.innerController.position.setPixels(772);
                              aaa=!aaa;

                              //key.currentState!.innerController.position.pointerScroll(772);
                              //key.currentState!.outerController.position.setPixels(150);
                              //nestedWebviewController!.nestedScrollController.innerScrollController.position.
                              //nestedWebviewController!.webViewController!.scrollTo(0, 772);
                              //nestedWebviewController!.nestedScrollController.innerScrollController!.position.setPixels(820);
                             // setPixels(772);
                              //nestedWebviewController!.webViewController!.runJavaScript("window.scrollBy(0, 300);");
                            /*  sl<ScrollHeightCubit>().updateScrollHeight(0);
                              sl<BackgroundCubit>().changeValue(true);
                              sl<ErrorTextCubit>().changeValue(true);*/
                              //Utils.showCallDialog(context);
                              //nestedWebviewController!.nestedScrollController.innerScrollController!.position.animateTo(500, duration: Duration(milliseconds: 10), curve: Curves.bounceOut);


                            });
                      } else {
                        return SizedBox();
                      }
                    }));
              }else{
                return SizedBox();
              }
            },

          ),



        ),
      ),
    );
  }
}
