

import 'package:flutter_bloc/flutter_bloc.dart';

class ScrollHeightCubit extends Cubit<double> {
  ScrollHeightCubit() : super(100.0);

  void updateScrollHeight(double height) {
    emit(height);
  }
}