import 'package:get_it/get_it.dart';
import 'package:kdrc_flutter/cubits/background_cubit.dart';
import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/cubits/inet_cubit.dart';
import 'package:kdrc_flutter/cubits/error_text_cubit.dart';
import 'package:kdrc_flutter/cubits/is_collapsed_cubit.dart';
import 'package:kdrc_flutter/cubits/phone_cubit.dart';
import 'package:kdrc_flutter/cubits/scroll_height_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_cubit.dart';
import 'package:kdrc_flutter/cubits/start_cubit/start_cubit.dart';
import 'package:kdrc_flutter/utils/nested_webview_controller.dart';
import 'package:kdrc_flutter/utils/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //cubits
  sl.registerLazySingleton(() => ScrollHeightCubit());
  sl.registerLazySingleton(() => IsCollapsedCubit());
  sl.registerLazySingleton(() => SettingsCubit());
  sl.registerLazySingleton(() => BoolCubit());
  sl.registerLazySingleton(() => ErrorTextCubit());
  sl.registerLazySingleton(() => BackgroundCubit());
  sl.registerLazySingleton(() => PhoneCubit());
  sl.registerLazySingleton(() => StartCubit());
  sl.registerLazySingleton(() => InetCubit());

  //external
  SharedPreferences settingPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => settingPrefs);

  //firebase-notification
  sl.registerLazySingleton(() => NotificationService.instance);

  sl.registerLazySingleton(() => NestedWebviewController());
}
