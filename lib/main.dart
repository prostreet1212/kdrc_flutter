import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit.dart';
import 'package:kdrc_flutter/pages/test/pdf_page.dart';
import 'package:kdrc_flutter/pages/test/sl.dart';
import 'package:kdrc_flutter/pages/sl_copy.dart';
import 'package:kdrc_flutter/pages/test/web_page.dart';
import 'package:kdrc_flutter/pages/test/web_page_copy.dart';
import 'package:kdrc_flutter/pages/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kdrc_flutter/locator_service.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Котласский реабилитационный центр',
      scrollBehavior: ScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home:PdfPage()
      home: WelcomePage(),
      /* BlocProvider<ScrollHeightCubit>(
        create: (context) => scrollHeightCubit,
        child: SlWebCopy(),
      ),*/
    );
  }
}
