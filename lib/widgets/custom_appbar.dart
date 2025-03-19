import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intrinsic_dimension/intrinsic_dimension.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/is_collapsed_cubit.dart';
import 'package:kdrc_flutter/pages/settings_page.dart';
import 'package:kdrc_flutter/widgets/dynamic_sliver.dart';
import 'package:kdrc_flutter/widgets/exit_dialog.dart';
import '../locator_service.dart';
import '../main.dart';
import '../utils/nested_webview_controller.dart';
import '../utils/utils.dart';
import 'custom_toast.dart';

class CustomAppBar extends StatefulWidget {
  CustomAppBar({super.key, required this.nestedWebviewController});

  NestedWebviewController nestedWebviewController;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  void loadFeedback() {
    //nestedWebviewController.webViewController!.loadRequest(Uri.parse(
    //'https://docs.google.com/gview?embedded=true&url=kdrc.ru/wp-content/uploads/2025/01/%D0%98%D0%B7%D0%BC%D0%B5%D0%BD%D0%B5%D0%BD%D0%B8%D1%8F-%D0%B2-%D0%A3%D1%81%D1%82%D0%B0%D0%B2-%D0%BE%D1%82-16.01.2025.pdf'));
    // nestedWebviewController.webViewController!.reload();
    if (sl<InetCubit>().state) {
      widget.nestedWebviewController.scrollStatus = ScrollStatus.forward;
      widget.nestedWebviewController.webViewController!
          .loadRequest(Uri.parse('https://kdrc.ru/obratnaya-svyaz'));
    } else {
      fToast.showToast(
          child: CustomToast(),
          toastDuration: Duration(seconds: 2),
          gravity: ToastGravity.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IsCollapsedCubit>(
        create: (context) => sl<IsCollapsedCubit>(),
        child: BlocBuilder<IsCollapsedCubit, bool>(builder: (context, state) {
          return SliverOverlapAbsorber(
            handle: SliverOverlapAbsorberHandle(),
            //handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverSafeArea(
              sliver: ExtendedSliverAppbar(
                toolbarHeight: 60,
                background: Image.asset('assets/images/titleimage.png',
                fit: BoxFit.fitHeight,
                height: 220,
                ),
              )
              /*SliverAppBar(
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
                        : SizedBox(),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            Utils.createRoute(SettingsPage()),
                          );
                        },
                        icon: Icon(
                          Icons.settings,
                          color: Color.fromARGB(255, 32, 146, 131),
                        )),
                    state
                        ? IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => ExitDialog());
                            },
                            icon: Icon(
                              Icons.exit_to_app,
                              color: Color.fromARGB(255, 32, 146, 131),
                            ))
                        : SizedBox(),
                  ],
                  backgroundColor: Color.fromARGB(255, 247, 172, 119),
                  foregroundColor: Colors.red,
                  surfaceTintColor: Colors.yellow,
                  expandedHeight: expHeight,
                  collapsedHeight: 56,
                  pinned: true,
                  flexibleSpace: Stack(
                    children: [
                      FlexibleSpaceBar(
                        titlePadding: EdgeInsets.only(right: 0),
                        collapseMode: CollapseMode.pin,
                        background: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                          child: Image.asset('assets/images/titleimage.png',
                              frameBuilder: (context, child, frame,
                                  wasSynchronouslyLoaded) {
                            if (frame == null) {
                              // Изображение еще загружается
                              return Center(
                                child:
                                    CircularProgressIndicator(), // Индикатор загрузки
                              );
                            } else {
                              // Изображение загружено, узнаем его размеры
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final imageSize =
                                    (context.findRenderObject() as RenderBox)
                                        .size;
                                setState(() {
                                  expHeight =
                                      imageSize.height; // Обновляем высоту
                                });
                              });
                              return child;
                            }
                          }
                              //fit: BoxFit.cover,
                              ),
                        ),
                        /*Image.asset(
                      'assets/images/titleimage.png',
                      fit: BoxFit.cover,
                    ),*/
                      ),
                      state
                          ? SizedBox()
                          : Positioned(
                              right: 16,
                              bottom: 16,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      loadFeedback();
                                    },
                                    child: Image.asset(
                                        'assets/images/ic_feedback1.png'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(56, 56),
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              color: Color.fromARGB(
                                                  255, 32, 146, 131))),
                                      shadowColor: Colors.grey[400],
                                      padding: EdgeInsets.all(5),
                                      backgroundColor: Colors.transparent,
                                      // <-- Button color
                                      foregroundColor: Colors
                                          .transparent, // <-- Splash color
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => ExitDialog());
                                    },
                                    child: Icon(
                                      Icons.exit_to_app,
                                      color: Color.fromARGB(255, 249, 176, 116),
                                      size: 36,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(56, 56),
                                      shape: CircleBorder(
                                          side: BorderSide(
                                              color: Color.fromARGB(
                                                  255, 32, 146, 131))),
                                      shadowColor: Colors.grey[400],
                                      padding: EdgeInsets.all(5),
                                      backgroundColor: Colors.transparent,
                                      // <-- Button color
                                      foregroundColor: Colors
                                          .transparent, // <-- Splash color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  )),*/
            ),
          );
        }));
  }
}
