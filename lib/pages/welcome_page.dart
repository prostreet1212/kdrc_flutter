import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kdrc_flutter/pages/main_page.dart';
import '../utils/utils.dart';

class WelcomePage extends StatefulWidget {
   const WelcomePage({super.key});





  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
/*  Route createRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  }*/
  Future<void> runRoutePage() async {
    await Future.delayed(const Duration(milliseconds: 700)).then((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        Utils.createRoute(
          const MainPage(
          ),
        ),
      );
    });
  }


  @override
  void initState() {
    super.initState();
    runRoutePage();
  }


  @override
  Widget build(BuildContext context) {
log('build WelcomePage');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 80,
              ),
              Image.asset(
                'assets/images/logo.png',
                width: 180,
              ),
              const Text(
                'Котласский\n реабилитационный центр',
                textAlign: TextAlign.center,
                style:TextStyle(
                  fontFamily: 'WelcomeFont',
                    fontSize: 18,
                    color: Color(0xFF757575),
                   // color: Colors.grey
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
