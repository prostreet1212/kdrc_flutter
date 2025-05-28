import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/settings_cubit/settings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../locator_service.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const String _isCallingKey = 'isCalling';
  static const String _isPushKey = 'isPush';
  static const String _isFirstPushRequestKey = 'isFirstPushRequest';

  SettingsCubit()
    : super(
        SettingsState(
          isCalling: sl<SharedPreferences>().getBool(_isCallingKey) ?? true,
          isPush: sl<SharedPreferences>().getBool(_isPushKey) ?? false,
          isFirstPushRequest:
              sl<SharedPreferences>().getBool(_isFirstPushRequestKey) ?? true,
        ),
      );

  void getSettings() {
    bool isCalling = sl<SharedPreferences>().getBool(_isCallingKey) ?? true;
    bool isPush = sl<SharedPreferences>().getBool(_isPushKey) ?? true;
    emit(state.copyWith(isCalling: isCalling, isPush: isPush));
  }

  Future<void> updateIsCalling(bool value) async {
    await sl<SharedPreferences>().setBool(_isCallingKey, value);
    emit(state.copyWith(isCalling: value));
  }

  Future<void> updateIsPush(bool value) async {
    await sl<SharedPreferences>().setBool(_isPushKey, value);
    emit(state.copyWith(isPush: value));
  }

  Future<void> updateIsFirstPushRequest(bool value) async {
    await sl<SharedPreferences>().setBool(_isFirstPushRequestKey, value);
    emit(state.copyWith(isFirstPushRequest: value));
  }
}
