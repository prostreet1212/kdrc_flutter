import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/background_cubit.dart';
import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/error_text_cubit.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/widgets/sliver_webview/background_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../cubits/scroll_height_cubit.dart';
import '../../locator_service.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../main.dart';




class SliverWebview extends StatelessWidget {
  SliverWebview({super.key, /*required this.nestedWebviewController*/});

  //NestedWebviewController nestedWebviewController;


  @override
  Widget build(BuildContext context) {
    final double textPadding = MediaQuery.of(context).size.height / 2.15;
    double heightScreen = MediaQuery.of(context).size.height;
    double topPadding = MediaQueryData.fromView(View.of(context)).padding.top;
    double bottomPadding =
        MediaQueryData.fromView(View.of(context)).padding.bottom;
    double heightWebview = heightScreen - topPadding - bottomPadding - 56;
    return BlocConsumer<InetCubit, bool>(
      listenWhen: (prev,next){
        return prev!=next;
      },
      listener: (context, state) {
        if (state) {
          if (nestedWebviewController!.isFirstRun &&
              /*nestedWebviewController.internetStatus == false*/sl<InetCubit>().state==true/*false*/) {
            print('перезагрузка');
            sl<ErrorTextCubit>().changeValue(true);
            nestedWebviewController!.scrollStatus = ScrollStatus.reload;
            nestedWebviewController!.webViewController!.reload();
            //nestedWebviewController!.isFirstRun = false;
          } else {
            //nestedWebviewController!.isFirstRun = false;
          }
          /*nestedWebviewController.internetStatus = true*/;
        } else {
          //nestedWebviewController.internetStatus = false;
          if (nestedWebviewController!.isFirstRun &&
              /*nestedWebviewController.internetStatus == false*/sl<InetCubit>().state==false) {
            sl<ScrollHeightCubit>().updateScrollHeight(0);
            sl<ErrorTextCubit>().changeValue(false);
          }
        }
      },
      builder: (context1, state) {
        return
        Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverStack(insetOnOverlap: true, children: [
                  MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (context) => sl<BackgroundCubit>(),
                      ),
                      BlocProvider(
                        create: (context) => sl<ErrorTextCubit>(),
                      ),
                    ],
                    child: BlocBuilder<BackgroundCubit, bool>(
                        builder: (context, state) {
                      if (state) {
                        return BackgroundWidget();
                      } else {
                        return SliverFillRemaining(

                        );
                      }
                    }),
                  ),
                  BlocProvider<ErrorTextCubit>(
                      create: (c) => sl<ErrorTextCubit>(),
                      child: BlocBuilder<ScrollHeightCubit, double>(
                          buildWhen: (next, prev) {
                        return next != prev;
                      }, builder: (context, state) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if(nestedWebviewController!.isStep){
                            if (nestedWebviewController!.scrollStatus ==
                                ScrollStatus.forward) {
                              if (nestedWebviewController!.sliverKey1.currentState!.innerController.offset>0
                              ) {
                                nestedWebviewController!.sliverKey1.currentState!.innerController.position.setPixels(0);
                              }
                            } else if (nestedWebviewController!.scrollStatus ==
                                ScrollStatus.prev) {
                             double maxScrollExtent= nestedWebviewController!.sliverKey1.currentState!.innerController.position.maxScrollExtent;
                             if(maxScrollExtent<nestedWebviewController!.oldScroll){
                               nestedWebviewController!.sliverKey1.currentState!.innerController.position.setPixels(maxScrollExtent);
                             }else{
                               nestedWebviewController!.sliverKey1.currentState!.innerController.position.setPixels(nestedWebviewController!.oldScroll);
                             }

                              //если обновить страницу
                            } else {}
                            nestedWebviewController!.isStep=false;
                          }

                        });
                        return SliverToNestedScrollBoxAdapter(
                            childExtent: state,
                            onScrollOffsetChanged: (scrollOffset) {
                             if (nestedWebviewController!.isStep) {
                               // nestedWebviewController.isStep = false;
                              } else {
                                double y = scrollOffset;
                                if (Platform.isAndroid) {
                                  y *= View.of(context).devicePixelRatio;
                                }
                                nestedWebviewController!.webViewController!
                                    .scrollTo(0, y.ceil());
                              }
                            },
                            //718,5
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: 1,
                                itemBuilder: (c, i) {
                                  return Container(
                                    //width: 500,
                                    //height:718.5,
                                    //height:1252,
                                    height: heightWebview,
                                    child: WebViewWidget(
                                      controller: nestedWebviewController!
                                          .webViewController!,
                                    ),
                                  );
                                })
                            );
                      }))
                ]),
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
      },
    );
  }
}
