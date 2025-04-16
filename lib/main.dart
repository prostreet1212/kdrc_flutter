import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/phone_cubit.dart';

import 'package:kdrc_flutter/cubits/start_cubit/start_cubit.dart';
import 'package:kdrc_flutter/pages/main_page.dart';

import 'package:kdrc_flutter/pages/welcome_page.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/utils/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kdrc_flutter/locator_service.dart' as di;

import 'cubits/scroll_height_cubit.dart';
import 'cubits/settings_cubit/settings_cubit.dart';
import 'cubits/start_cubit/start_state.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
FToast fToast = FToast();
NestedWebviewController? nestedWebviewController;

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await di.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await NotificationService.instance.initialize();
  await di.sl<NotificationService>().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PhoneCubit>(
          create: (context) => di.sl<PhoneCubit>()..checkPhone(),
        ),
        BlocProvider<ScrollHeightCubit>(
          create: (context) => di.sl<ScrollHeightCubit>(),
        ),
        BlocProvider<StartCubit>(
          create: (context) => di.sl<StartCubit>(),
        ),
        BlocProvider<InetCubit>(
          create: (context) => di.sl<InetCubit>(),
        ),
        BlocProvider<SettingsCubit>(
          create: (c) => di.sl<SettingsCubit>(),
        )
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        builder: FToastBuilder(),
        debugShowCheckedModeBanner: false,
        title: 'Котласский реабилитационный центр',
        scrollBehavior: ScrollBehavior(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocBuilder<StartCubit, StartState>(
          // future: NotificationService.instance.getInitialMessage(),
          builder: ((context, state) {

            if (state is StartPush) {
              // Если приложение было открыто через уведомление
              return MainPage();
            } else {
              return WelcomePage();
            }
          }),
        ),
      ),
    );
  }
}
