import 'dart:math';
import 'card.dart';

class Deck {
  List<GameCard> _cards = [];
  final Random _random = Random();

  Deck() {
    _initializeDeck();
  }

  void _initializeDeck() {
    _cards.clear();
    
    // 숫자 1과 10은 각각 4장씩
    for (int i = 0; i < 4; i++) {
      _cards.add(GameCard(value: 1, id: '1_$i'));
      _cards.add(GameCard(value: 10, id: '10_$i'));
    }
    
    // 숫자 2~9는 각각 2장씩
    for (int value = 2; value <= 9; value++) {
      for (int i = 0; i < 2; i++) {
        _cards.add(GameCard(value: value, id: '${value}_$i'));
      }
    }
    
    shuffle();
  }

  void shuffle() {
    _cards.shuffle(_random);
  }

  GameCard? drawCard() {
    if (_cards.isEmpty) return null;
    return _cards.removeLast();
  }

  List<GameCard> drawCards(int count) {
    List<GameCard> drawnCards = [];
    for (int i = 0; i < count && _cards.isNotEmpty; i++) {
      drawnCards.add(_cards.removeLast());
    }
    return drawnCards;
  }

  int get remainingCards => _cards.length;

  bool get isEmpty => _cards.isEmpty;

  void reset() {
    _initializeDeck();
  }

  List<GameCard> get cards => List.unmodifiable(_cards);
} 