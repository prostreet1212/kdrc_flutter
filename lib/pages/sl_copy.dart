
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/settings_cubit.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/widgets/custom_appbar.dart';
import 'package:kdrc_flutter/widgets/sliver_webview.dart';

import '../locator_service.dart';
import '../main.dart';
import '../utils/utils.dart';


class SlWebCopy extends StatefulWidget {
  const SlWebCopy({super.key});

  @override
  State<SlWebCopy> createState() => _SlWebCopyState();
}

class _SlWebCopyState extends State<SlWebCopy> {
  late NestedWebviewController nestedWebviewController;
  @override
  void initState() {
    super.initState();
     nestedWebviewController = NestedWebviewController(
        initialUrl: 'https://kdrc.ru/novosti', context: context);
    nestedWebviewController.init();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        if (await nestedWebviewController.webViewController!.canGoBack()) {
          nestedWebviewController.scrollStatus = ScrollStatus.prev;
          nestedWebviewController.webViewController!.goBack();
          return false;
        }else{
          return true;
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollView(
            controller: nestedWebviewController.nestedScrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                CustomAppBar(nestedWebviewController: nestedWebviewController,),
              ];
            },
            body:
                SliverWebview(nestedWebviewController: nestedWebviewController),
          ),

          floatingActionButton: BlocProvider<SettingsCubit>(
              create: (c)=>sl<SettingsCubit>()..getCalling(),
          child: BlocBuilder<SettingsCubit,bool>(
              builder: (context,state){
                if(state){
                  return FloatingActionButton(
                      backgroundColor: Colors.grey[50],
                      shape: const CircleBorder(),
                      child: Icon(
                        Icons.call,
                        color: Color.fromARGB(255, 247, 176, 116),
                        size: 36,
                      ),
                      onPressed: () {
                        Utils.showCallDialog(context);
                      });
                }else{
                  return SizedBox();
                }
              })
          ),
        ),
      ),
    );
  }
}
