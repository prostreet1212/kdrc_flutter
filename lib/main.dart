
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kdrc_flutter/cubits/call_request_is_opened_cubit.dart';

import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/phone_cubit.dart';

import 'package:kdrc_flutter/cubits/start_cubit/start_cubit.dart';
import 'package:kdrc_flutter/pages/main_page.dart';

import 'package:kdrc_flutter/pages/welcome_page.dart';

import 'package:kdrc_flutter/locator_service.dart' as di;
import 'package:kdrc_flutter/utils/notification_service.dart';

import 'cubits/scroll_height_cubit.dart';
import 'cubits/settings_cubit/settings_cubit.dart';
import 'cubits/start_cubit/start_state.dart';
import 'firebase_options.dart';





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
  await di.sl<NotificationService>().initialize();

  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
   //final FToast fToast = FToast();
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
        ),
        BlocProvider<CallRequestIsOpenedCubit>(
          create: (c) => di.sl<CallRequestIsOpenedCubit>(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        builder: FToastBuilder(),
        debugShowCheckedModeBanner: false,
        title: 'Котласский реабилитационный центр',
        //scrollBehavior: const ScrollBehavior(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocBuilder<StartCubit, StartState>(
          builder: ((context, state) {
            if (state is StartPush) {
              // Если приложение было открыто через уведомление
              return const MainPage();
            } else {
              return const WelcomePage( );
            }
          }),
        ),
      ),
    );
  }
}
