
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InetCubit extends Cubit<bool> {
  //late final StreamSubscription<InternetStatus> internetListener;
  InternetConnection internetChecker=InternetConnection();/*.createInstance(
    customCheckOptions: [
      InternetCheckOption(uri: Uri.parse('https://google.com')),
    ],
  );*/
  late StreamSubscription<InternetStatus> internetListener;

  InetCubit() : super(true) {
    //init();
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
    internetListener.cancel();
    return super.close();
  }
}