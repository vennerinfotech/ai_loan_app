/// Model representing a step in the registration flow.
class RegistrationStep {
  final int index;
  final String title;
  final bool isCompleted;

  const RegistrationStep({
    required this.index,
    required this.title,
    this.isCompleted = false,
  });

  RegistrationStep copyWith({
    int? index,
    String? title,
    bool? isCompleted,
  }) {
    return RegistrationStep(
      index: index ?? this.index,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
