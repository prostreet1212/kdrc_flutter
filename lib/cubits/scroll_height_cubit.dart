

import 'package:flutter_bloc/flutter_bloc.dart';

class ScrollHeightCubit extends Cubit<double> {
  ScrollHeightCubit() : super(0.0);

  void updateScrollHeight(double height) {
    emit(height);
  }
}