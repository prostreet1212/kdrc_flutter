

import 'package:flutter_bloc/flutter_bloc.dart';

class IsCollapsedCubit extends Cubit<bool> {
  IsCollapsedCubit() : super(false);

  void updateIsCollapsed(bool isCollapsed) {
    emit(isCollapsed);
  }
}