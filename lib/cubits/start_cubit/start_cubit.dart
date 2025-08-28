import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdrc_flutter/cubits/start_cubit/start_state.dart';

class StartCubit extends Cubit<StartState> {
  StartCubit() : super(const StartEmpty('https://kdrc.ru/novosti'));

  //StartCubit() : super(StartEmpty('https://flutter.dev'));

  void changeValue(String url) {
    emit(StartPush(url));
  }
}
