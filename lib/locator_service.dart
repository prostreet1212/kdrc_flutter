

import 'package:get_it/get_it.dart';
import 'package:kdrc_flutter/cubits/bool_cubit.dart';
import 'package:kdrc_flutter/cubits/internet_cubit.dart';
import 'package:kdrc_flutter/cubits/is_collapsed_cubit.dart';
import 'package:kdrc_flutter/cubits/scroll_height_cubit.dart';
import 'package:kdrc_flutter/cubits/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl=GetIt.instance;

Future<void> init()async{
  //cubits
  sl.registerLazySingleton(()=>ScrollHeightCubit());
  sl.registerLazySingleton(()=>IsCollapsedCubit());
  sl.registerLazySingleton(()=>SettingsCubit());
  sl.registerLazySingleton(()=>BoolCubit());
  sl.registerLazySingleton(()=>InternetCubit());

  //external
  SharedPreferences settingPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => settingPrefs);

}