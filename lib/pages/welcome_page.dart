import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kdrc_flutter/pages/test/web_page.dart';
import 'package:kdrc_flutter/pages/test/web_page_copy.dart';

import '../cubits/scroll_height_cubit.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Route createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          BlocProvider<ScrollHeightCubit>(
        create: (context) => ScrollHeightCubit(),
        //child: WebPageCopy(),
        child: WebPage(),
      ),
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
  }

  runRoutePage() async {
    await Future.delayed(const Duration(milliseconds: 700), () {
      Navigator.pushReplacement(
        context,
        createRoute(),
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
                style: GoogleFonts.robotoSerif(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
