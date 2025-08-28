import 'package:equatable/equatable.dart';

abstract class StartState extends Equatable {
  final String url;

  const StartState(this.url);

  @override
  List<Object?> get props => [];
}

class StartPush extends StartState {
  const StartPush(super.url);

  @override
  List<Object?> get props => [url];
}

class StartEmpty extends StartState {
  const StartEmpty(super.url);

  @override
  List<Object?> get props => [url];
}
