import 'package:flutter_bloc/flutter_bloc.dart';

class BoolCubit extends Cubit<bool> {
  BoolCubit() : super(true);

  void changeValue(bool value) {
    emit(value);
  }
}