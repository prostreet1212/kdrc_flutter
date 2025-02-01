import 'package:flutter/material.dart';

import 'package:kdrc_flutter/web_page.dart';
import 'package:kdrc_flutter/web_page2.dart';
import 'package:kdrc_flutter/web_page3.dart';
import 'package:kdrc_flutter/web_page_test.dart';

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
      home: WebPage3(),
    );
  }
}

