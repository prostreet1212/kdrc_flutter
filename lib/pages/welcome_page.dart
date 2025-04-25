import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kdrc_flutter/pages/main_page.dart';
import '../utils/utils.dart';

class WelcomePage extends StatefulWidget {
   const WelcomePage({super.key,required this.fToast,required this.callRequestResult});
  final FToast fToast;
  final bool callRequestResult;


  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Route createRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context1, animation, secondaryAnimation, child) {
        // Анимация перехода SecondScreen справа налево
        var slideAnimation = Tween<Offset>(
          begin: Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 500),
    );
  }
  runRoutePage() async {
    await Future.delayed(const Duration(milliseconds: 700), ()async {
      if(context.mounted){
        await Navigator.pushReplacement(
          context,
          Utils.createRoute(
            MainPage(fToast: widget.fToast,callRequestResult: widget.callRequestResult,),
          ),
        );
      }

    });
  }


  @override
  void initState() {
    super.initState();
    runRoutePage();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 80,
              ),
              Image.asset(
                'assets/images/logo.png',
                width: 180,
              ),
              Text(
                'Котласский\n реабилитационный центр',
                textAlign: TextAlign.center,
                style:TextStyle(
                  fontFamily: 'WelcomeFont',
                    fontSize: 18,
                    color: Colors.grey[600]
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
