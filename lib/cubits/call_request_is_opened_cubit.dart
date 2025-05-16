import 'package:flutter_bloc/flutter_bloc.dart';

class CallRequestIsOpenedCubit extends Cubit<bool> {
  CallRequestIsOpenedCubit() : super(false);

  void changeValue(bool value) {
    emit(value);
  }
}