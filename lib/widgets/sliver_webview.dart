import 'dart:io';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverStack(
                  children: [
                SliverAppBar(
                  expandedHeight: 719,
                  collapsedHeight: 719,
                  flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                    color: Colors.white,
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/asdf3.png',
                          fit: BoxFit.cover,
                        ),
                        Center(
                          child:  Text(
                                  'Ошибка загрузки. Проверьте подключение к сети и дождитесь загрузки страницы',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          )

                        )
                      ],
                    ),
                  )),
                ),
                BlocProvider<InternetCubit>(
                  create: (c) => sl<InternetCubit>(),
                  child: BlocBuilder<InternetCubit, bool>(
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


                  }),
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

class Background extends StatefulWidget {
  const Background({
    super.key,
    required this.controller,
  });

  final ScrollController controller;

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  bool isReady = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        isReady = true;
      });
    });
    widget.controller.addListener(_listener);
    super.initState();
  }

  void _listener() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: const NetworkImage(
          'https://background-tiles.com/overview/mixed-colors/patterns/large/1148.png'),
      repeat: ImageRepeat.repeatY,
      alignment: Alignment(
        0,
        !isReady
            ? 0
            : -widget.controller.offset /
                MediaQuery.of(context).size.height *
                3,
      ),
    );
  }
}
