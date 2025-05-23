

import 'package:flutter_bloc/flutter_bloc.dart';

class ScrollHeightCubit extends Cubit<double> {
  ScrollHeightCubit() : super(0);

  void updateScrollHeight(double height1) {
    emit(height1);
  }
}
/*
class ScrollHeightState {
  final double height;


  ScrollHeightState({
    required this.height,

  });

  ScrollHeightState copyWith({
    double? height,
  }) {
    return ScrollHeightState(
      height: height ?? this.height,
    );
  }
}*/