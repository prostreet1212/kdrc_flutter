import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intrinsic_size_builder/intrinsic_size_builder.dart';
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
                  leading: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: IconButton(
                        icon: Icon(
                          Icons.keyboard_backspace,
                          color: Color.fromARGB(255, 32, 146, 131),
                          size: 30,
                        ),
                      onPressed: null,),
                  ),
                  backgroundColor: Color.fromARGB(255, 247, 172, 119),
                  foregroundColor: Colors.red,
                  surfaceTintColor: Colors.yellow,
                  //expandedHeight: 216.7,
                  //expandedHeight: MediaQuery.of(context).size.width*0.551820728,
                  expandedHeight:
                      MediaQuery.of(context).size.width * 0.552125 + 0.1,
                  //expandedHeight: 441.7,
                  floating: true,
                  collapsedHeight: 56,
                  pinned: true,
                  flexibleSpace: Stack(
                    children: [
                      FlexibleSpaceBar(
                        titlePadding: EdgeInsets.only(right: 0),
                        collapseMode: CollapseMode.pin,
                        background: Container(
                          color: Colors.white,
                          child: Image.asset(
                            'assets/images/titleimage.png',
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
                  )),
            ),
          );
        }));
  }
}
