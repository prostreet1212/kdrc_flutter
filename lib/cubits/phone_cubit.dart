import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneCubit extends Cubit<bool> {
  PhoneCubit() : super(true);

  void checkPhone(bool value) async{
    if (await canLaunchUrl(Uri.parse('tel:+79210779641'))) {
    emit(true);
  }else{
      emit(false);
    }
  }
}