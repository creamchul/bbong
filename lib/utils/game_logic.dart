import 'dart:math';
import '../models/card.dart';
import '../models/player.dart';
import 'constants.dart';

class GameLogic {
  // 월남뽕 게임 결과 판정
  static GameResult determineResult(List<GameCard> playerCards, GameCard vietnamCard) {
    if (playerCards.length != 2) return GameResult.pending;
    
    List<int> values = playerCards.map((card) => card.value).toList();
    values.sort();
    int min = values[0];
    int max = values[1];
    int vietnam = vietnamCard.value;
    
    // 묻기: 월남 카드가 플레이어 카드 중 하나와 같음
    if (vietnam == min || vietnam == max) {
      return GameResult.bury;
    }
    
    // 승리: 월남 카드가 플레이어 카드 사이에 있음
    if (vietnam > min && vietnam < max) {
      return GameResult.win;
    }
    
    // 패배: 월남 카드가 범위 밖
    return GameResult.lose;
  }
  
  // AI의 베팅 전략 (개선된 전략)
  static int getAiBet(Player aiPlayer, [int? totalPot]) {
    if (!aiPlayer.isAlive || aiPlayer.coins < GameConstants.minBet) {
      return 0;
    }
    
    // 베팅 가능한 최대 금액 계산 (판돈보다 높으면 안됨)
    int maxBet = totalPot != null && totalPot > 0 
        ? (aiPlayer.coins < totalPot ? aiPlayer.coins : totalPot)
        : aiPlayer.coins;
    
    List<GameCard> hand = aiPlayer.hand;
    if (hand.isEmpty) return 0;
    
    // 죽기 조건 확인
    if (aiPlayer.shouldConsiderDying()) {
      // 80% 확률로 죽기
      if (_random.nextDouble() < 0.8) {
        return 0;
      }
    }
    
    // 카드 분석
    List<int> values = hand.map((card) => card.value).toList();
    values.sort();
    int min = values[0];
    int max = values[1];
    int cardDiff = max - min;
    
    // 승률 대략 계산 (월남 카드가 min과 max 사이에 올 확률)
    int favorableOutcomes = 0;
    int totalOutcomes = 0;
    
    for (int i = 1; i <= 10; i++) {
      int cardCount = (i == 1 || i == 10) ? 4 : 2; // 1,10은 4장, 나머지는 2장
      totalOutcomes += cardCount;
      
      if (i > min && i < max) {
        favorableOutcomes += cardCount;
      }
    }
    
    // 이미 나온 카드 3장 제외 (플레이어 2장 + AI 2장 - 겹치는 2장)
    totalOutcomes -= 3;
    double winProbability = totalOutcomes > 0 ? favorableOutcomes / totalOutcomes : 0.0;
    
    // 베팅 전략 (1000원 단위)
    if (winProbability < 0.3) {
      // 승률이 낮으면 50% 확률로 죽거나 최소 베팅
      if (_random.nextDouble() < 0.5) {
        return 0; // 죽기
      }
      return GameConstants.minBet; // 최소 베팅
    } else if (winProbability > 0.6) {
      // 승률이 높으면 적극적으로 베팅
      int aggressiveBet = 3000;
      return aggressiveBet > maxBet ? maxBet : aggressiveBet;
    } else {
      // 중간 승률이면 보통 베팅
      int moderateBet = 2000;
      return moderateBet > maxBet ? maxBet : moderateBet;
    }
  }
  
  // AI가 죽을지 결정
  static bool shouldAiDie(Player aiPlayer) {
    if (!aiPlayer.shouldConsiderDying()) return false;
    
    // 연속 숫자나 같은 카드일 때 80% 확률로 죽기
    return _random.nextDouble() < 0.8;
  }
  
  // 승률 계산 (플레이어 카드 기준)
  static double calculateWinProbability(List<GameCard> playerCards, List<GameCard> remainingCards) {
    if (playerCards.length != 2) return 0.0;
    
    List<int> values = playerCards.map((card) => card.value).toList();
    values.sort();
    int min = values[0];
    int max = values[1];
    
    if (min == max || max - min == 1) {
      return 0.0; // 같은 카드이거나 연속 카드면 승률 0%
    }
    
    int winningCards = 0;
    int buryingCards = 0;
    
    for (GameCard card in remainingCards) {
      if (card.value > min && card.value < max) {
        winningCards++;
      } else if (card.value == min || card.value == max) {
        buryingCards++;
      }
    }
    
    // 승률만 계산 (묻기는 제외)
    return remainingCards.isEmpty ? 0.0 : winningCards / remainingCards.length;
  }
  
  // 베팅 배당률 계산
  static int calculatePayout(int bet, GameResult result) {
    switch (result) {
      case GameResult.win:
        return bet * 2; // 2배 배당
      case GameResult.bury:
        return bet; // 원금 반환 (다음 라운드로 이월)
      case GameResult.lose:
      case GameResult.die:
        return 0; // 손실
      case GameResult.pending:
        return bet; // 원금 반환
    }
  }
  
  // 게임 결과 메시지
  static String getResultMessage(GameResult result) {
    switch (result) {
      case GameResult.win:
        return AppStrings.winMessage;
      case GameResult.lose:
        return AppStrings.loseMessage;
      case GameResult.bury:
        return AppStrings.buryMessage;
      case GameResult.die:
        return AppStrings.dieMessage;
      case GameResult.pending:
        return '';
    }
  }
  
  // 카드 분포 체크 (디버그용)
  static Map<int, int> getCardDistribution(List<GameCard> cards) {
    Map<int, int> distribution = {};
    for (int i = 1; i <= 10; i++) {
      distribution[i] = 0;
    }
    
    for (GameCard card in cards) {
      distribution[card.value] = (distribution[card.value] ?? 0) + 1;
    }
    
    return distribution;
  }
  
  static final _random = Random();
} 