import 'card.dart';

class Player {
  final String id;
  final String name;
  List<GameCard> hand = [];
  int bet = 0;
  int coins = 1000; // 시작 코인
  bool isAlive = true; // 죽기 여부

  Player({
    required this.id,
    required this.name,
    this.coins = 1000,
  });

  void addCard(GameCard card) {
    hand.add(card);
  }

  void addCards(List<GameCard> cards) {
    hand.addAll(cards);
  }

  void clearHand() {
    hand.clear();
  }

  void placeBet(int amount) {
    if (amount <= coins) {
      bet = amount;
      coins -= amount;
    }
  }

  void winBet(int amount) {
    coins += amount;
    bet = 0;
  }

  void loseBet() {
    bet = 0;
  }

  void die() {
    isAlive = false;
  }

  void revive() {
    isAlive = true;
  }

  // 플레이어 카드가 연속 숫자인지 확인
  bool hasConsecutiveCards() {
    if (hand.length < 2) return false;
    List<int> values = hand.map((card) => card.value).toList();
    values.sort();
    return (values[1] - values[0]).abs() == 1;
  }

  // 플레이어 카드가 같은 숫자인지 확인
  bool hasSameCards() {
    if (hand.length < 2) return false;
    return hand[0].value == hand[1].value;
  }

  // 죽기를 권장할 상황인지 확인
  bool shouldConsiderDying() {
    return hasConsecutiveCards() || hasSameCards();
  }

  @override
  String toString() {
    return 'Player(name: $name, hand: $hand, bet: $bet, coins: $coins, alive: $isAlive)';
  }
} 