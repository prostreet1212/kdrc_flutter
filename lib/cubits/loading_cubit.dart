import 'package:flutter_bloc/flutter_bloc.dart';

class LoadingCubit extends Cubit<bool> {
  LoadingCubit() : super(true);

  void changeValue(bool value) {
    emit(value);
  }
}
