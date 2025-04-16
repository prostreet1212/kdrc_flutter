class SettingsState {
  final bool isCalling;
  final bool isPush;

  SettingsState({
    required this.isCalling,
    required this.isPush,
  });

  SettingsState copyWith({
    bool? isCalling,
    bool? isPush,
  }) {
    return SettingsState(
      isCalling: isCalling ?? this.isCalling,
      isPush: isPush ?? this.isPush,
    );
  }
}