import 'package:flutter_bloc/flutter_bloc.dart';

class ErrorTextCubit extends Cubit<bool> {
  ErrorTextCubit() : super(true);

  void changeValue(bool value) {
    emit(value);
  }
}
