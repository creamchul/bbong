class GameCard {
  final int value;
  final String id;
  bool isRevealed;

  GameCard({
    required this.value,
    required this.id,
    this.isRevealed = false,
  });

  @override
  String toString() {
    return 'Card(value: $value, id: $id, revealed: $isRevealed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameCard && other.value == value && other.id == id;
  }

  @override
  int get hashCode => value.hashCode ^ id.hashCode;

  GameCard copyWith({
    int? value,
    String? id,
    bool? isRevealed,
  }) {
    return GameCard(
      value: value ?? this.value,
      id: id ?? this.id,
      isRevealed: isRevealed ?? this.isRevealed,
    );
  }
} 