import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kdrc_flutter/cubits/scroll_height_cubit.dart';

import '../locator_service.dart';
import '../utils/nested_webview_controller.dart';
import 'background_cubit.dart';
import 'loading_cubit.dart';
import 'error_text_cubit.dart';

class InetCubit extends Cubit<bool> {
  //late final StreamSubscription<InternetStatus> internetListener;
  InternetConnection internetChecker = InternetConnection.createInstance(
    customCheckOptions: [
      InternetCheckOption(uri: Uri.parse('https://google.com')),
    ],
  );
  late StreamSubscription<InternetStatus> internetListener;

  InetCubit() : super(true) {
    //init();
  }

  void init() {
    // Подписываемся на изменения состояния интернета

    internetListener = internetChecker.onStatusChange.listen((status) async {
      //  if (kDebugMode) {
      //await Future.delayed(const Duration(seconds: 2));
      print('интернет ${status == InternetStatus.connected}');
      //  }
      emit(status == InternetStatus.connected);
    });
  }

  @override
  Future<void> close() {
    internetListener.cancel();
    return super.close();
  }
}
