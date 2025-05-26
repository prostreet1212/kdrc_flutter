import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kdrc_flutter/cubits/background_cubit.dart';
import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/error_text_cubit.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';

import '../../cubits/scroll_height_cubit.dart';
import '../../cubits/start_cubit/start_cubit.dart';
import '../../locator_service.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'background_widget.dart';

class SliverWebview extends StatelessWidget {
  final FToast fToast;

  const SliverWebview({super.key, required this.fToast});

  @override
  Widget build(BuildContext context) {
    //final double textPadding = MediaQuery.of(context).size.height / 2.15;
    double heightScreen = MediaQuery.of(context).size.height;
    double topPadding = MediaQueryData.fromView(View.of(context)).padding.top;
    double bottomPadding =
        MediaQueryData.fromView(View.of(context)).padding.bottom;
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
                sl<NestedWebviewController>().webViewController.reload();
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
          builder: (context1, state) {
            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverStack(
                      insetOnOverlap: true,
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
                                return BackgroundWidget();
                              } else {
                                return SliverFillRemaining();
                              }
                            },
                          ),
                        ),
                        BlocProvider<ErrorTextCubit>(
                          create: (c) => sl<ErrorTextCubit>(),
                          child: BlocBuilder<ScrollHeightCubit, ScrollHeightState>(
                         /*   buildWhen: (next, prev) {
                              bool isBuild=(next != prev)||(next == prev);
                              return isBuild;
                            },*/
                            builder: (context, state) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                               /* if(sl<NestedWebviewController>().isCrashed){
                                  sl<NestedWebviewController>()
                                      .nestedScrollController
                                      .innerScrollController!
                                      .position
                                      .setPixels(300/*sl<NestedWebviewController>().currentPixel*/);
                                }*/
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
                                  } else if(sl<NestedWebviewController>()
                                      .scrollStatus ==
                                      ScrollStatus.reload) {

                                    double currentInnerPixel=sl<NestedWebviewController>().currentInnerPixel;

                                    double maxScrollExtent =
                                        sl<NestedWebviewController>()
                                            .nestedScrollController
                                            .innerScrollController!
                                            .position
                                            .maxScrollExtent;
                                    print('сдвиг ${currentInnerPixel}');
                                    print('макс ${maxScrollExtent}');
                                      sl<NestedWebviewController>()
                                          .nestedScrollController
                                          .innerScrollController!
                                          .position
                                      //.setPixels(752.4545454545455);
                                          .setPixels(currentInnerPixel-0.0000000000001);





                                  }
                                    sl<NestedWebviewController>().isStep = false;
                                }
                              });
                              return SliverToNestedScrollBoxAdapter(
                                childExtent: state.height,
                                onScrollOffsetChanged: (scrollOffset) {
                                  if (sl<NestedWebviewController>().isStep) {
                                    // nestedWebviewController.isStep = false;
                                  } else {
                                    double y = scrollOffset;
                                    if (Platform.isAndroid) {
                                      y *= View.of(context).devicePixelRatio;
                                    }
                                    //if(sl<NestedWebviewController>().webViewController!=null){
                                    sl<NestedWebviewController>()
                                        .webViewController
                                        .scrollTo(x: 0, y: y.ceil());
                                    //  }
                                  }
                                },
                                //718,5
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: 1,
                                  itemBuilder: (c, i) {
                                    return SizedBox(
                                      height: heightWebview,
                                      child: InAppWebView(
                                        onWebViewCreated: (c) {
                                          sl<NestedWebviewController>()
                                              .onWebViewCreated(c);
                                        },
                                        initialSettings: InAppWebViewSettings(
                                          javaScriptEnabled: true,
                                          transparentBackground: true,
                                          useShouldOverrideUrlLoading: true,
                                          useOnRenderProcessGone: true,
                                        ),
                                        initialUrlRequest: URLRequest(
                                          url: WebUri(
                                            sl<StartCubit>().state.url,
                                          ),
                                        ),
                                        onLoadStart: (c, uri) {
                                          sl<NestedWebviewController>()
                                              .onLoadStart(c, uri);
                                        },
                                        onLoadStop: (c, uri) {
                                          sl<NestedWebviewController>()
                                              .onLoadStop(c, uri);
                                        },
                                        onProgressChanged: (c, progress) {
                                          sl<NestedWebviewController>()
                                              .onProgressChanged(c, progress);
                                        },
                                        shouldOverrideUrlLoading: (
                                          c,
                                          navigationAction,
                                        ) async {
                                          return sl<NestedWebviewController>()
                                              .shouldOverrideUrlLoading(
                                                c,
                                                navigationAction,
                                                fToast,
                                                context,
                                              );
                                        },
                                        onReceivedError: (c, request, error) {
                                          sl<NestedWebviewController>()
                                              .onReceivedError(error);
                                        },
                                        onRenderProcessGone: (
                                          c,
                                          details,
                                        ) async {
                                          print(
                                            'onRenderProcessGone: $details',
                                          );
                                          sl<NestedWebviewController>()
                                              .isCrashed = true;
                                        },
                                        onWebContentProcessDidTerminate: (c) {
                                          print(
                                            'onWebContentProcessDidTerminate',
                                          );
                                        },
                                        onReceivedHttpError:
                                            (c, request, response) {},
                                      ),
                                      /*WebViewWidget(
                                          controller: sl<NestedWebviewController>()
                                              .webViewController,
                                        ),*/
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
                        return LinearProgressIndicator(
                          color: Colors.blueAccent[200],
                          backgroundColor: Colors.blueAccent[50],
                        );
                      } else {
                        return SizedBox();
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
