import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/is_collapsed_cubit.dart';
import 'package:kdrc_flutter/pages/settings_page.dart';
import 'package:kdrc_flutter/widgets/exit_dialog.dart';
import '../locator_service.dart';
import '../locator_service.dart' as di;
import '../utils/nested_webview_controller.dart';
import '../utils/utils.dart';
import 'custom_toast.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key});



  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  void loadFeedback() {
    if (sl<InetCubit>().state) {
      sl<NestedWebviewController>().scrollStatus = ScrollStatus.forward;
      sl<NestedWebviewController>().webViewController!.loadUrl(
        urlRequest: URLRequest(url: WebUri('https://kdrc.ru/obratnaya-svyaz')),
      );
    } else {
      di.sl<NestedWebviewController>().fToast.showToast(
        child: const CustomToast(message: 'Проверьте подключение к сети интернет'),
        toastDuration: const Duration(seconds: 2),
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IsCollapsedCubit>(
      create: (context) => sl<IsCollapsedCubit>(),
      child: BlocBuilder<IsCollapsedCubit, bool>(
        builder: (context, state) {
          return SliverOverlapAbsorber(
             handle: SliverOverlapAbsorberHandle(),
            //handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverSafeArea(
              sliver: SliverAppBar(
                actions: [
                  state
                      ? Visibility(
                          visible: state,
                          child: IconButton(
                            onPressed: () {
                              loadFeedback();
                            },
                            icon: Image.asset(
                              'assets/images/ic_feedback_green.png',
                              width: 23,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        Utils.createRoute(const SettingsPage()),
                      );
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Color.fromARGB(255, 32, 146, 131),
                    ),
                  ),
                  state
                      ? IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const ExitDialog(),
                            );
                          },
                          icon: const Icon(
                            Icons.exit_to_app,
                            color: Color.fromARGB(255, 32, 146, 131),
                          ),
                        )
                      : const SizedBox(),
                ],
                leading: Padding(
                  padding: const EdgeInsets.only(bottom: 10, right: 16),
                  child: IconButton(
                    icon: const Icon(
                      //Icons.keyboard_backspace,
                      Icons.arrow_back,
                      //Icons.arrow_back_ios,
                      color: Color.fromARGB(255, 32, 146, 131),
                      size: 25,
                    ),
                    onPressed: () async {
                      if (await sl<NestedWebviewController>().webViewController!
                          .canGoBack()) {
                        sl<NestedWebviewController>().scrollStatus =
                            ScrollStatus.prev;
                        sl<NestedWebviewController>().isStep = true;
                        sl<NestedWebviewController>().webViewController!
                            .goBack();
                      } else {
                        di.sl<NestedWebviewController>().fToast.showToast(
                          child: const CustomToast(
                            message:
                                // 'Это начальная странцица',
                                'Это начальная страница. Дальнейший переход не требуется',
                          ),
                          toastDuration: const Duration(seconds: 2),
                          gravity: ToastGravity.BOTTOM,
                        );
                      }
                    },
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 247, 172, 119),
                foregroundColor: Colors.red,
                surfaceTintColor: Colors.yellow,
                expandedHeight:
                    MediaQuery.of(context).size.width * 0.552125 + 0.1,
                floating: true,
                collapsedHeight: 56,
                pinned: true,
                flexibleSpace: Stack(
                  children: [
                    FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(right: 0),
                      collapseMode: CollapseMode.pin,
                      background: Container(
                        color: Colors.white,
                        child: Image.asset('assets/images/titleimage.png'),
                      ),
                    ),
                    state
                        ? const SizedBox()
                        : Positioned(
                            right: 16,
                            bottom: 16,
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    loadFeedback();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(56, 56),
                                    shape: const CircleBorder(
                                      side: BorderSide(
                                        color: Color.fromARGB(
                                          255,
                                          32,
                                          146,
                                          131,
                                        ),
                                      ),
                                    ),
                                    shadowColor: Colors.grey[400],
                                    padding: const EdgeInsets.all(5),
                                    backgroundColor: Colors.transparent,
                                    foregroundColor:
                                        Colors.transparent, // <-- Splash color
                                  ),
                                  child: Image.asset(
                                    'assets/images/ic_feedback1.png',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => const ExitDialog(),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(56, 56),
                                    shape: const CircleBorder(
                                      side: BorderSide(
                                        color: Color.fromARGB(
                                          255,
                                          32,
                                          146,
                                          131,
                                        ),
                                      ),
                                    ),
                                    shadowColor: Colors.grey[400],
                                    padding: const EdgeInsets.all(5),
                                    backgroundColor: Colors.transparent,
                                    // <-- Button color
                                    foregroundColor:
                                        Colors.transparent, // <-- Splash color
                                  ),
                                  child: const Icon(
                                    Icons.exit_to_app,
                                    color: Color.fromARGB(255, 249, 176, 116),
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
