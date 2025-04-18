
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';


class InetCubit extends Cubit<bool> {
  //late final StreamSubscription<InternetStatus> internetListener;
  InternetConnectionChecker internetChecker=InternetConnectionChecker.instance;/*.createInstance(
    customCheckOptions: [
      InternetCheckOption(uri: Uri.parse('https://google.com')),
    ],
  );*/
  late StreamSubscription<InternetConnectionStatus> internetListener;

  InetCubit() : super(true) {
    //init();
  }

  void init() {
    // Подписываемся на изменения состояния интернета

    internetListener=internetChecker.onStatusChange.listen((status) {
      print('интернет ${status == InternetConnectionStatus.connected}');
      emit(status == InternetConnectionStatus.connected);
    });
  }

  @override
  Future<void> close() {
    internetListener.cancel();
    return super.close();
  }
}