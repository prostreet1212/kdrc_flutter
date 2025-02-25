import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/main.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../cubits/scroll_height_cubit.dart';
import '../locator_service.dart';

class SliverWebview extends StatelessWidget {
  SliverWebview({super.key, required this.nestedWebviewController});

  NestedWebviewController nestedWebviewController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      nestedWebviewController.nestedScrollController.enableScroll(context);
      return Stack(
        children: [
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              BlocBuilder<ScrollHeightCubit, double>(builder: (context, state) {
                return SliverToNestedScrollBoxAdapter(
                    childExtent: state,
                    onScrollOffsetChanged: (scrollOffset) {
                      double y = scrollOffset;
                      print('scroll: $y');
                      if (Platform.isAndroid) {
                        y *= View.of(context).devicePixelRatio;
                      }
                      nestedWebviewController.webViewController!
                          .scrollTo(0, y.ceil());
                    },
                    child: WebViewWidget(
                        controller:
                            nestedWebviewController.webViewController!));
              })
              /* ValueListenableBuilder(
                        valueListenable: nestedWebviewController.scrollHeightNotifier,
                        builder: (context, scrollHeight, child) {
                          return
                        })*/
            ],
          ),
          BlocProvider(
            create: (c) => sl<BoolCubit>(),
            child: BlocBuilder<BoolCubit, bool>(builder: (c, loadingState) {
              if(loadingState){
                return LinearProgressIndicator(
                  color: Colors.blueAccent[200],
                  backgroundColor: Colors.blueAccent[50],
                );
              }else{
                return SizedBox();
              }

            }),
          ),
        ],
      );
    });
    ;
  }
}
