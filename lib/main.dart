import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/web_page.dart';
import 'package:kdrc_flutter/web_page_copy.dart';

import 'cubits/scroll_height_cubit.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      scrollBehavior: ScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:   BlocProvider<ScrollHeightCubit>(
        create: (context) => ScrollHeightCubit(),
        child: WebPage(),
      ),
    );
  }
}

