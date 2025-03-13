import 'package:flutter_bloc/flutter_bloc.dart';

class BackgroundCubit extends Cubit<bool> {
  BackgroundCubit() : super(true);

  void changeValue(bool value) {
    emit(value);
  }
}