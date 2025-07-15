import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../locator_service.dart';

class CallRequestIsOpenedCubit extends Cubit<bool> {
  CallRequestIsOpenedCubit() : super(
    Platform.isAndroid?
      false:sl<SharedPreferences>().getBool('iosCallRequest')??false);

  void changeValue(bool value)async {
    if(Platform.isIOS){
      await sl<SharedPreferences>().setBool('iosCallRequest', value);
    }
    emit(value);
  }

  /*void getIosCallRequest() {
    bool isCalling = sl<SharedPreferences>().getBool('iosCallRequest') ?? false;
    emit(isCalling);
  }*/
}