import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/is_collapsed_cubit.dart';
import 'package:kdrc_flutter/widgets/exit_dialog.dart';

IsCollapsedCubit isCollapsedCubit=IsCollapsedCubit();
class CustomAppBar extends StatelessWidget {
  CustomAppBar({super.key,});

  //bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IsCollapsedCubit>(
        create: (context) => isCollapsedCubit,
    child: BlocBuilder<IsCollapsedCubit,bool>(
        builder: (context,state){
          return SliverOverlapAbsorber(
            handle: SliverOverlapAbsorberHandle(),
            sliver: SliverSafeArea(
              sliver: SliverAppBar(
                  actions: [
                    state
                        ? Visibility(
                      visible: state,
                      child: IconButton(
                        onPressed: () {},
                        icon: Image.asset(
                          'assets/images/ic_feedback_green.png',
                          width: 23,
                        ),
                      ),
                    )
                        : SizedBox(),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.settings,
                          color: Color.fromARGB(255, 32, 146, 131),
                        )),
                    state
                        ? IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.exit_to_app,
                          color: Color.fromARGB(255, 32, 146, 131),
                        ))
                        : SizedBox(),
                  ],
                  backgroundColor: Color.fromARGB(255, 247, 172, 119),
                  foregroundColor: Colors.red,
                  surfaceTintColor: Colors.yellow,
                  expandedHeight: 220,
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
                              fit: BoxFit.cover,
                            ),
                          )
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
                                onPressed: () {},
                                child:
                                Image.asset('assets/images/ic_feedback1.png'),
                                /*Icon(
                            Icons.message,
                            color: Color.fromARGB(255, 249, 176, 116),
                            size: 36,
                          ),*/
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(56, 56),
                                  shape: CircleBorder(
                                      side: BorderSide(
                                          color:
                                          Color.fromARGB(255, 32, 146, 131))),
                                  shadowColor: Colors.grey[400],
                                  padding: EdgeInsets.all(5),
                                  backgroundColor: Colors.transparent,
                                  // <-- Button color
                                  foregroundColor:
                                  Colors.transparent, // <-- Splash color
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(context: context,
                                      builder: (context)=>ExitDialog());
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
                                          color:
                                          Color.fromARGB(255, 32, 146, 131))),
                                  shadowColor: Colors.grey[400],
                                  padding: EdgeInsets.all(5),
                                  backgroundColor: Colors.transparent,
                                  // <-- Button color
                                  foregroundColor:
                                  Colors.transparent, // <-- Splash color
                                ),
                              ),
                            ],
                          ))
                    ],
                  )),
            ),
          );
        })
    );
  }
}
