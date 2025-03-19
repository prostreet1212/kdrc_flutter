
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InetCubit extends Cubit<bool> {
  //late final StreamSubscription<InternetStatus> internetListener;
  InternetConnection internetChecker=InternetConnection();
  late StreamSubscription<InternetStatus> internetListener;

  InetCubit() : super(false) {
    init();
  }

  void init() {
    // Подписываемся на изменения состояния интернета

    internetListener=internetChecker.onStatusChange.listen((status) {
      print('интернет ${status == InternetStatus.connected}');
      emit(status == InternetStatus.connected);
    });
  }

  @override
  Future<void> close() {
    //_internetChecker.dispose();
    //internetListener.cancel();
    return super.close();
  }
}