
class ReservationActionState {
  final bool isLoading;
  final String? error;

  const ReservationActionState({
    this.isLoading = false,
    this.error,
  });

  ReservationActionState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ReservationActionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}