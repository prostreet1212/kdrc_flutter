import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kdrc_flutter/pages/test/sl.dart';
import 'package:kdrc_flutter/pages/sl_copy.dart';
import 'package:kdrc_flutter/pages/test/web_page.dart';
import 'package:kdrc_flutter/pages/test/web_page_copy.dart';
import 'package:kdrc_flutter/pages/welcome_page.dart';

import 'cubits/scroll_height_cubit.dart';

ScrollHeightCubit scrollHeightCubit=ScrollHeightCubit();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Котласский реабилитационный центр',
      scrollBehavior: ScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home:OnlyInWeb()
      home: WelcomePage(),
     /* BlocProvider<ScrollHeightCubit>(
        create: (context) => scrollHeightCubit,
        child: SlWebCopy(),
      ),*/
    );
  }
}

