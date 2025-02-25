


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../locator_service.dart';

class SettingsCubit extends Cubit<bool>{
  SettingsCubit( ) : super(true);

  void getCalling(){
//sl<SharedPreferences>().getBool('key');
    bool isCalling=sl<SharedPreferences>().getBool('isCalling')??true;
    emit(isCalling);
  }


  void changeCalling(bool isCalling) {
    sl<SharedPreferences>().setBool('isCalling',isCalling);
    emit(isCalling);
  }

}