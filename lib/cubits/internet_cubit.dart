import 'package:flutter_bloc/flutter_bloc.dart';

class InternetCubit extends Cubit<bool> {
  InternetCubit() : super(true);

  void changeValue(bool value) {
    emit(value);
  }
}