import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/background_cubit.dart';
import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/error_text_cubit.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';

import '../../cubits/scroll_height_cubit.dart';
import '../../locator_service.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../src/widget.dart';
import 'webview_widget.dart';
import 'background_widget.dart';

class SliverWebview extends StatelessWidget {
  const SliverWebview({super.key});

  @override
  Widget build(BuildContext context) {
    //final double textPadding = MediaQuery.of(context).size.height / 2.15;
    double heightScreen = MediaQuery.of(context).size.height;
    double topPadding = MediaQueryData.fromView(View.of(context)).padding.top;
    double bottomPadding = MediaQueryData.fromView(
      View.of(context),
    ).padding.bottom;
    double heightWebview = heightScreen - topPadding - bottomPadding - 56;
    return LayoutBuilder(
      builder: (context, constraints) {
        sl<NestedWebviewController>().nestedScrollController.enableScroll(
          context,
        );
        sl<NestedWebviewController>().nestedScrollController.enableCenterScroll(
          constraints,
        );
        return BlocConsumer<InetCubit, bool>(
          listenWhen: (prev, next) {
            return prev != next;
          },
          listener: (context, state) {
            if (state) {
              if (sl<NestedWebviewController>().isFirstRun &&
                  sl<InetCubit>().state == true /*false*/ ) {
                print('перезагрузка');
                sl<ErrorTextCubit>().changeValue(true);
                sl<NestedWebviewController>().scrollStatus =
                    ScrollStatus.reload;
                sl<NestedWebviewController>().webViewController!.reload();
                sl<NestedWebviewController>().isFirstRun = false;
              } else {
                sl<NestedWebviewController>().isFirstRun = false;
              }
            } else {
              if (sl<NestedWebviewController>().isFirstRun &&
                  sl<InetCubit>().state == false) {
                sl<ScrollHeightCubit>().updateScrollHeight(0);
                sl<ErrorTextCubit>().changeValue(false);
              }
            }
          },
          builder: (context/*1*/, state) {
            return Stack(
              children: [
                CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverStack(
                      // insetOnOverlap: true,
                      children: [
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
                                return const BackgroundWidget();
                              } else {
                                return const SliverFillRemaining();
                              }
                            },
                          ),
                        ),
                        BlocProvider<ErrorTextCubit>(
                          create: (c) => sl<ErrorTextCubit>(),
                          child: BlocBuilder<ScrollHeightCubit, ScrollHeightState>(
                            builder: (context, state) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (sl<NestedWebviewController>().isStep) {
                                  if (sl<NestedWebviewController>()
                                          .scrollStatus ==
                                      ScrollStatus.forward) {
                                    if (sl<NestedWebviewController>()
                                            .nestedScrollController
                                            .innerScrollController!
                                            .offset >
                                        0) {
                                      sl<NestedWebviewController>()
                                          .nestedScrollController
                                          .innerScrollController!
                                          .position
                                          .setPixels(0);
                                    }
                                  } else if (sl<NestedWebviewController>()
                                          .scrollStatus ==
                                      ScrollStatus.prev) {
                                    double maxScrollExtent =
                                        sl<NestedWebviewController>()
                                            .nestedScrollController
                                            .innerScrollController!
                                            .position
                                            .maxScrollExtent;
                                    if (maxScrollExtent <
                                        sl<NestedWebviewController>()
                                            .oldScroll) {
                                      sl<NestedWebviewController>()
                                          .nestedScrollController
                                          .innerScrollController!
                                          .position
                                          .setPixels(maxScrollExtent);
                                    } else {
                                      sl<NestedWebviewController>()
                                          .nestedScrollController
                                          .innerScrollController!
                                          .position
                                          .setPixels(
                                            sl<NestedWebviewController>()
                                                .oldScroll,
                                          );
                                    }

                                    //если обновить страницу
                                  } else if (sl<NestedWebviewController>()
                                          .scrollStatus ==
                                      ScrollStatus.reload) {
                                    double currentInnerPixel =
                                        sl<NestedWebviewController>()
                                            .currentInnerPixel;

                                    double maxScrollExtent =
                                        sl<NestedWebviewController>()
                                            .nestedScrollController
                                            .innerScrollController!
                                            .position
                                            .maxScrollExtent;
                                    log('сдвиг $currentInnerPixel');
                                    log('макс $maxScrollExtent');
                                    sl<NestedWebviewController>()
                                        .nestedScrollController
                                        .innerScrollController!
                                        .position
                                        //.setPixels(752.4545454545455);
                                        .setPixels(
                                          currentInnerPixel - 0.0000000000001,
                                        );
                                  }
                                  sl<NestedWebviewController>().isStep = false;
                                  //для ios выставить значение forward чтобы переключиться с prev
                                  if (Platform.isIOS) {
                                    sl<NestedWebviewController>().scrollStatus =
                                        ScrollStatus.forward;
                                  }
                                }
                              });
                              return SliverToNestedScrollBoxAdapter(
                                childExtent: state.height,
                                onScrollOffsetChanged: (scrollOffset) async {
                                  if (sl<NestedWebviewController>().isStep) {
                                    // nestedWebviewController.isStep = false;
                                  } else {
                                    double y = scrollOffset;
                                    if (Platform.isAndroid) {
                                      y *= View.of(context).devicePixelRatio;
                                    }
                                    //if(sl<NestedWebviewController>().webViewController!=null){
                                    sl<NestedWebviewController>()
                                        .webViewController!
                                        .scrollTo(x: 0, y: y.ceil());
                                    //  }
                                  }
                                },
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 1,
                                  padding: const EdgeInsets.all(0),
                                  itemBuilder: (c, i) {
                                    return SizedBox(
                                      height: heightWebview,
                                      child: const WebViewVidget(),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                //шкала загрузки веб-страницы
                BlocProvider(
                  create: (c) => sl<BoolCubit>(),
                  child: BlocBuilder<BoolCubit, bool>(
                    builder: (c, loadingState) {
                      if (loadingState) {
                        return const LinearProgressIndicator(
                          color: Color(0xFF448AFF),
                          //backgroundColor: Colors.blueAccent[50],
                          backgroundColor: Color(0xFFE1F5FE),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
