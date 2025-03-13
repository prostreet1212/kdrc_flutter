import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/background_cubit.dart';
import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/cubits/internet_cubit.dart';
import 'package:kdrc_flutter/main.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../cubits/scroll_height_cubit.dart';
import '../locator_service.dart';
import 'package:sliver_tools/sliver_tools.dart';

class SliverWebview extends StatelessWidget {
  SliverWebview({super.key, required this.nestedWebviewController});

  NestedWebviewController nestedWebviewController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      nestedWebviewController.nestedScrollController.enableScroll(context);
      return Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.green,
          ),
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverStack(children: [
                BlocProvider(
                  create: (context) => sl<BackgroundCubit>(),
                  child: BlocBuilder<BackgroundCubit, bool>(
                      builder: (context, state) {
                        if(state){
                          return SliverAppBar(
                            expandedHeight: 719,
                            collapsedHeight: 719,
                            pinned: true,
                            flexibleSpace: FlexibleSpaceBar(
                                background: Container(
                                  color: Colors.white,
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        'assets/images/333.png',
                                        opacity: const AlwaysStoppedAnimation(0.7),
                                        fit: BoxFit.cover,
                                      ),
                                      BlocProvider(
                                        create: (context) => sl<InternetCubit>(),
                                        child: BlocBuilder<InternetCubit, bool>(
                                          builder: (context, internetStatetate) {
                                            if (internetStatetate) {
                                              return SizedBox();
                                            } else {
                                              return Align(
                                                  alignment: Alignment(0.5, 0.15),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 40),
                                                    child: Text(
                                                      'Ошибка загрузки. Проверьте подключение к сети и дождитесь загрузки страницы',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontStyle: FontStyle.italic,
                                                          color: Colors.grey[700]),
                                                    ),
                                                  ));
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                          );
                        }else{

                          return SliverFillRemaining();
                        }

                  }),
                ),

                BlocProvider<InternetCubit>(
                    create: (c) => sl<InternetCubit>(),
                    child: BlocBuilder<ScrollHeightCubit, double>(
                        builder: (context, state) {
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
                                nestedWebviewController.webViewController!),
                      );
                    })
                    /*BlocBuilder<InternetCubit, bool>(
                      builder: (context, internetState) {
                          if(internetState){
                            return  BlocBuilder<ScrollHeightCubit, double>(
                                builder: (context, state) {
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
                                        nestedWebviewController.webViewController!),
                                  );
                                });
                          }else{
                            return SliverFillRemaining();
                          }


                  }),*/
                    )
              ]),

              /* ValueListenableBuilder(
                        valueListenable: nestedWebviewController.scrollHeightNotifier,
                        builder: (context, scrollHeight, child) {
                          return
                        })*/
            ],
          ),
          //шкала загрузки веб-страницы
          BlocProvider(
            create: (c) => sl<BoolCubit>(),
            child: BlocBuilder<BoolCubit, bool>(builder: (c, loadingState) {
              if (loadingState) {
                return LinearProgressIndicator(
                  color: Colors.blueAccent[200],
                  backgroundColor: Colors.blueAccent[50],
                );
              } else {
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
