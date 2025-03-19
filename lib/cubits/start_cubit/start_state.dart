


 import 'package:equatable/equatable.dart';

abstract class StartState extends Equatable{
  String url;


  StartState(this.url);

  @override
  List<Object?> get props => [];
}

class StartPush extends StartState{
  StartPush(super.url);

  @override
  List<Object?> get props => [url];
}

 class StartEmpty extends StartState{

  StartEmpty(super.url);


   @override
   List<Object?> get props => [url];
 }