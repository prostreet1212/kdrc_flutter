class SettingsState {
  final bool isCalling;
  final bool isPush;
  final bool isFirstPushRequest;

  SettingsState({
    required this.isCalling,
    required this.isPush,
    required this.isFirstPushRequest,
  });

  SettingsState copyWith({
    bool? isCalling,
    bool? isPush,
    bool? isFirstPushRequest,
  }) {
    return SettingsState(
      isCalling: isCalling ?? this.isCalling,
      isPush: isPush ?? this.isPush,
      isFirstPushRequest: isFirstPushRequest ?? this.isFirstPushRequest,
    );
  }
}
