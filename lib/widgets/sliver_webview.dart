import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/background_cubit.dart';
import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/error_text_cubit.dart';
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
    return BlocConsumer<InetCubit, bool>(
      listener: (context, state) {
        if (state) {
          if (nestedWebviewController.isFirstRun &&
              nestedWebviewController.internetStatus == false) {
            sl<ErrorTextCubit>().changeValue(true);
            nestedWebviewController.scrollStatus = ScrollStatus.reload;
            nestedWebviewController.webViewController!.reload();
            nestedWebviewController.isFirstRun = false;
          } else {
            nestedWebviewController.isFirstRun = false;
          }
          nestedWebviewController.internetStatus = true;
        } else {
          nestedWebviewController.internetStatus = false;
          if (nestedWebviewController.isFirstRun &&
              nestedWebviewController.internetStatus == false) {
            sl<ScrollHeightCubit>().updateScrollHeight(0);
            sl<ErrorTextCubit>().changeValue(false);
          }
        }
      },
      builder: (context, state){
        return LayoutBuilder(builder: (context, constraints) {
          nestedWebviewController.nestedScrollController.enableScroll(context);
          return Stack(
            children: [
              // Container(
              //   width: double.infinity,
              //   height: double.infinity,
              //   color: Colors.transparent,
              // ),
              CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [

                  SliverStack(
                    positionedAlignment: Alignment.topLeft,
                      children: [
                    BlocProvider(
                      create: (context) => sl<BackgroundCubit>(),
                      child: BlocBuilder<BackgroundCubit, bool>(
                          builder: (context, state) {
                            if (state) {
                              return SliverToBoxAdapter(
                                child: Image.asset(
                                  'assets/images/555.png', // Укажи свой путь к изображению
                                  width: double.infinity, // Занимает всю ширину экрана
                                  //fit: BoxFit.cover, // Растягивает по ширине без масштабирования при прокрутке
                                ),
                              );
                              /*SliverAppBar(
                                expandedHeight: MediaQuery.of(context).size.width*1.83091418385536,
                                collapsedHeight: MediaQuery.of(context).size.width*1.83091418385536,
                                //expandedHeight: 719,
                                //collapsedHeight: 719,
                                pinned: true,
                                floating: true,
                                flexibleSpace: FlexibleSpaceBar(
                                    collapseMode: CollapseMode.pin,
                                    background: Container(
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.green,
                                      child: Stack(
                                        //fit: StackFit.expand,
                                        children: [
                                          Image.asset(
                                            'assets/images/444.png',
                                            fit: BoxFit.cover,
                                            opacity: const AlwaysStoppedAnimation(0.7),
                                            width: 800,
                                            //fit: BoxFit.cover,
                                          ),
                                          BlocProvider(
                                            create: (context) => sl<ErrorTextCubit>(),
                                            child: BlocBuilder<ErrorTextCubit, bool>(
                                              builder: (context, internetStatetate) {
                                                if (internetStatetate) {
                                                  return SizedBox();
                                                } else {
                                                  return Align(
                                                      alignment: Alignment(0.5, 0.15),
                                                      child: Padding(
                                                        padding:
                                                        const EdgeInsets.symmetric(
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
                              );*/
                            } else {
                              return SliverFillRemaining();
                            }
                          }),
                    ),
                    BlocProvider<ErrorTextCubit>(
                        create: (c) => sl<ErrorTextCubit>(),
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
      },
    );
  }
}
