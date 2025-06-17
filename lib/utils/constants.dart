import 'package:flutter/material.dart';

// 색상 상수
class AppColors {
  static const Color background = Color(0xFF1C1C1C);
  static const Color cardBorder = Color(0xFFC0392B);
  static const Color cardBackground = Color(0xFF2C2C2C);
  static const Color cardFace = Color(0xFFF8F9FA);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFBBBBBB);
  static const Color buttonPrimary = Color(0xFFC0392B);
  static const Color buttonSecondary = Color(0xFF34495E);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color danger = Color(0xFFE74C3C);
}

// 게임 상수
class GameConstants {
  static const int totalCards = 24;
  static const int cardsPerPlayer = 2;
  static const int startingCoins = 10000;
  static const int minBet = 1000;
  static const int maxPlayers = 5;
  static const int minPlayers = 2;
  static const int initialPot = 1000; // 판돈이 없을 때 인당 내는 금액
}

// 게임 결과 타입
enum GameResult {
  win,      // 승리
  lose,     // 패배
  bury,     // 묻기
  die,      // 죽기
  pending   // 대기중
}

// 게임 상태
enum GameState {
  waiting,    // 대기중
  dealing,    // 카드 분배중
  betting,    // 베팅중
  revealing,  // 카드 공개중
  finished    // 게임 종료
}

// 애니메이션 상수
class AnimationConstants {
  static const Duration cardFlip = Duration(milliseconds: 600);
  static const Duration cardDeal = Duration(milliseconds: 300);
  static const Duration resultDisplay = Duration(milliseconds: 1000);
  static const Duration buttonPress = Duration(milliseconds: 150);
}

// 문자열 상수
class AppStrings {
  static const String appName = '월남뽕';
  static const String singlePlay = '싱글 플레이';
  static const String multiPlay = '멀티 플레이';
  static const String openCard = '덮인 카드 열기';
  static const String die = '죽기';
  static const String nextRound = '다음 라운드';
  static const String bet = '베팅';
  static const String coins = '코인';
  static const String player = '플레이어';
  static const String ai = 'AI';
  static const String vietnam = '월남';
  static const String you = '당신';
  
  // 결과 메시지
  static const String winMessage = '승리!';
  static const String loseMessage = '패배!';
  static const String buryMessage = '묻기!';
  static const String dieMessage = '죽기!';
} 