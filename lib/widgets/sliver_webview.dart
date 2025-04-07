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
import 'package:nested_scroll_view_plus/nested_scroll_view_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../cubits/scroll_height_cubit.dart';
import '../locator_service.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../pages/sl_copy.dart';

final GlobalKey<NestedScrollViewState> key = GlobalKey();

class SliverWebview extends StatelessWidget {
  SliverWebview({super.key, required this.nestedWebviewController});

  NestedWebviewController nestedWebviewController;

  @override
  Widget build(BuildContext context) {
    final double textPadding = MediaQuery.of(context).size.height / 2.15;

    double heightScreen = MediaQuery.of(context).size.height;
    //EdgeInsets safeAreaPadding = MediaQuery.of(context).padding;
    double topPadding = MediaQueryData.fromView(View.of(context)).padding.top;
    double bottomPadding = MediaQueryData.fromView(View.of(context)).padding.bottom;
    double heightWebview = heightScreen - topPadding - bottomPadding - 56;
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
      builder: (context1, state) {
        return LayoutBuilder(builder: (context1, constraints) {
          nestedWebviewController.nestedScrollController.enableScroll(context);
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          print('высота: $screenHeight , ширина:$screenWidth');
          return Stack(
            children: [
              CustomScrollView(
                controller: null,
                physics: AlwaysScrollableScrollPhysics(),
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
                          return SliverToBoxAdapter(
                            key: PageStorageKey('aaa'),
                            child: Container(
                              //color: Colors.green,
                              child: Stack(
                                //alignment: Alignment.center,
                                //fit: StackFit.passthrough,
                                children: [
                                  Image.asset(
                                    'assets/images/background.png',
                                    fit: BoxFit.cover,
                                    opacity: const AlwaysStoppedAnimation(0.7),
                                    width: double.infinity,
                                    //fit: BoxFit.cover,
                                  ),
                                  BlocBuilder<ErrorTextCubit, bool>(
                                    builder: (context, internetStatetate) {
                                      if (internetStatetate) {
                                        return SizedBox();
                                      } else {
                                        return Align(
                                          alignment: Alignment(0, 0.9),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: screenWidth / 5,
                                                //9.5,
                                                right: screenWidth / 5,
                                                //9.5,
                                                /*  left: 40,
                                                    right: 40,*/
                                                //top: textPadding,
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2.15),
                                            child: Text(
                                              'Ошибка загрузки. Проверьте подключение к сети и дождитесь загрузки страницы',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey[700]),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
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
                              // if(aaa==false){
                              double y = scrollOffset;
                              if (Platform.isAndroid) {
                                y *= View.of(context).devicePixelRatio;
                              }
                              nestedWebviewController.webViewController!
                                  .scrollTo(0, y.ceil());
                              //  }
                            },
                            //718,5
                            child: ListView.builder(

                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: 1,
                                    itemBuilder: (c, i) {
                                      return Container(
                                        width: 500,
                                        //height:718.5,
                                        height: heightWebview,
                                        child: WebViewWidget(
                                          controller: nestedWebviewController
                                              .webViewController!,
                                        ),
                                      );
                                    })
                           /* WebViewWidget(
                                controller: nestedWebviewController
                                    .webViewController!),*/
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
        });
      },
    );
  }
}
