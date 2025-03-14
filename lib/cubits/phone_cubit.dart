import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneCubit extends Cubit<bool> {
  PhoneCubit() : super(true);

  Future<void> checkPhone() async{
    if (await canLaunchUrl(Uri.parse('tel:+78183730050'))) {
    emit(true);
  }else{
      emit(false);
    }
  }
}