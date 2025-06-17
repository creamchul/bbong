import 'card.dart';
import 'deck.dart';
import 'player.dart';
import '../utils/constants.dart';
import '../utils/game_logic.dart';

class Game {
  final List<Player> players = [];
  late Deck deck;
  GameCard? vietnamCard; // 현재 플레이어의 월남 카드
  GameState state = GameState.waiting;
  int currentRound = 1;
  int totalPot = 0; // 전체 판돈 (누적)
  Player? winner;
  Map<String, GameCard?> playerVietnamCards = {}; // 각 플레이어별 월남 카드
  
  // 턴제 시스템
  int currentPlayerIndex = 0;
  bool isCurrentPlayerTurn = false;
  List<Player> roundOrder = []; // 이번 라운드 순서
  int firstPlayerIndex = 0; // 처음 선을 정한 플레이어 인덱스
  bool hasSelectedFirstPlayer = false; // 선을 이미 결정했는지
  Set<String> playersWhoPlayed = {}; // 이번 라운드에서 행동한 플레이어들
  
  Game() {
    deck = Deck();
  }
  
  // 선 결정을 위한 카드 준비 (플레이어가 선택할 수 있도록)
  List<GameCard> prepareFirstPlayerCards() {
    deck.reset();
    List<GameCard> availableCards = [];
    
    // 카드 풀에서 랜덤하게 여러 장 준비 (플레이어가 선택할 수 있도록)
    for (int i = 0; i < 6; i++) { // 6장 중에서 선택
      GameCard? card = deck.drawCard();
      if (card != null) {
        availableCards.add(card);
      }
    }
    
    return availableCards;
  }
  
  // 플레이어와 AI의 카드 선택 처리
  Map<String, int> setFirstPlayerCards(int humanCardValue, int aiCardValue) {
    Map<String, int> playerCards = {
      'human': humanCardValue,
      'ai': aiCardValue,
    };
    
    // 가장 높은 카드를 뽑은 플레이어 찾기
    int maxValue = 0;
    String firstPlayerId = '';
    
    playerCards.forEach((playerId, cardValue) {
      if (cardValue > maxValue) {
        maxValue = cardValue;
        firstPlayerId = playerId;
      }
    });
    
    // firstPlayerIndex 설정
    for (int i = 0; i < players.length; i++) {
      if (players[i].id == firstPlayerId) {
        firstPlayerIndex = i;
        break;
      }
    }
    
    return playerCards;
  }

  void addPlayer(Player player) {
    if (players.length < GameConstants.maxPlayers) {
      players.add(player);
    }
  }

  void removePlayer(String playerId) {
    players.removeWhere((player) => player.id == playerId);
  }

  Player? getPlayer(String playerId) {
    try {
      return players.firstWhere((player) => player.id == playerId);
    } catch (e) {
      return null;
    }
  }

  bool canStartGame() {
    return players.length >= GameConstants.minPlayers && 
           players.every((player) => player.coins >= GameConstants.minBet);
  }

  void startNewRound() {
    state = GameState.dealing;
    
    // 첫 라운드이거나 판돈이 0원이면 각자 초기 판돈 지불
    if (totalPot == 0) {
      _payInitialPot();
    }
    
    // 라운드 시작 시 플레이어 행동 기록 초기화
    playersWhoPlayed.clear();
    
    // 각 플레이어의 월남 카드 기록 초기화 (새 라운드)
    playerVietnamCards.clear();
    
    // 모든 플레이어 카드 초기화 및 베팅 상태 리셋
    for (Player player in players) {
      player.clearHand();
      player.revive();
      // 베팅은 리셋하지 않음 (판돈 유지)
    }
    
    // 덱 리셋 및 셔플
    deck.reset();
    
    // 각 플레이어에게 2장씩 카드 분배
    for (Player player in players) {
      List<GameCard> cards = deck.drawCards(GameConstants.cardsPerPlayer);
      player.addCards(cards);
    }
    
    // 월남 카드는 각 플레이어가 베팅할 때마다 개별적으로 뽑음
    vietnamCard = null;
    
    // 턴 순서 설정 (라운드마다 선 교체)
    _setupRoundOrder();
    
    state = GameState.betting;
    isCurrentPlayerTurn = true;
  }
  
  void _payInitialPot() {
    // 판돈이 없을 때 각 플레이어가 초기 판돈 지불
    for (Player player in players) {
      if (player.coins >= GameConstants.initialPot) {
        player.coins -= GameConstants.initialPot;
        totalPot += GameConstants.initialPot;
      }
    }
  }
  
  void _setupRoundOrder() {
    // 생존한 플레이어들만 순서에 포함
    roundOrder = players.where((player) => player.coins >= GameConstants.minBet).toList();
    
    // 라운드마다 선을 바꿔줌 (처음 정한 선부터 시작해서 순서대로)
    if (roundOrder.isNotEmpty) {
      // players 배열에서 현재 라운드의 선을 계산
      int roundFirstPlayerIndex = (firstPlayerIndex + currentRound - 1) % players.length;
      
      // roundOrder에서 해당 플레이어의 인덱스 찾기
      String firstPlayerId = players[roundFirstPlayerIndex].id;
      currentPlayerIndex = 0; // 기본값
      
      for (int i = 0; i < roundOrder.length; i++) {
        if (roundOrder[i].id == firstPlayerId) {
          currentPlayerIndex = i;
          break;
        }
      }
    }
  }

  // 현재 플레이어의 턴을 처리하는 함수
  GameResult processCurrentPlayerTurn(int betAmount) {
    if (roundOrder.isEmpty || !isCurrentPlayerTurn) {
      return GameResult.pending;
    }
    
    Player currentPlayer = roundOrder[currentPlayerIndex];
    
    // 현재 플레이어가 행동했음을 기록
    playersWhoPlayed.add(currentPlayer.id);
    
    if (betAmount == 0) {
      // 죽기 선택
      currentPlayer.die();
      _nextPlayer();
      return GameResult.die;
    }
    
    // 베팅 처리
    currentPlayer.placeBet(betAmount);
    
    // 현재 플레이어를 위한 새로운 월남 카드 뽑기
    GameCard? currentVietnamCard = deck.drawCard();
    if (currentVietnamCard != null) {
      currentVietnamCard.isRevealed = true;
      playerVietnamCards[currentPlayer.id] = currentVietnamCard;
      vietnamCard = currentVietnamCard; // 현재 표시용
      state = GameState.revealing;
      
      // 결과 판정
      GameResult result = GameLogic.determineResult(currentPlayer.hand, currentVietnamCard);
      
      switch (result) {
        case GameResult.win:
          // 승리: 베팅한 금액의 2배를 받음 (원금 + 상금)
          int prizeAmount = betAmount; // 상금 (베팅액과 동일)
          if (totalPot >= prizeAmount) {
            // 원금은 이미 placeBet에서 차감되었으므로, 원금 + 상금을 지급
            currentPlayer.winBet(betAmount + prizeAmount);
            totalPot -= prizeAmount; // 판돈에서 상금만 차감
          } else {
            // 판돈이 부족하면 원금 + 남은 판돈만 지급
            currentPlayer.winBet(betAmount + totalPot);
            totalPot = 0;
          }
          _endRound(); // 승리하면 라운드 종료
          break;
        case GameResult.bury:
          // 묻기: 베팅금이 판돈에 추가
          totalPot += betAmount;
          currentPlayer.bet = 0; // 베팅 리셋
          _nextPlayer(); // 다음 플레이어로
          break;
        case GameResult.lose:
          // 패배: 베팅금이 판돈에 추가
          totalPot += betAmount;
          currentPlayer.loseBet();
          _nextPlayer(); // 다음 플레이어로
          break;
        case GameResult.die:
          currentPlayer.loseBet();
          _nextPlayer();
          break;
        case GameResult.pending:
          break;
      }
      
      return result;
    }
    
    return GameResult.pending;
  }
  
  void _nextPlayer() {
    // 모든 플레이어가 행동했는지 확인
    bool allPlayersPlayed = roundOrder.every((player) => playersWhoPlayed.contains(player.id));
    
    if (allPlayersPlayed) {
      // 모든 플레이어가 행동했으면 라운드 종료
      _endRound();
      return;
    }
    
    // 아직 행동하지 않은 플레이어 찾기
    List<Player> playersNotPlayed = roundOrder.where((player) => 
        !playersWhoPlayed.contains(player.id) && player.isAlive).toList();
    
    if (playersNotPlayed.isEmpty) {
      // 살아있으면서 아직 행동하지 않은 플레이어가 없으면 라운드 종료
      _endRound();
      return;
    }
    
    // 다음 플레이어로 턴 이동 (아직 행동하지 않은 플레이어 중에서)
    int attempts = 0;
    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % roundOrder.length;
      attempts++;
      
      // 무한루프 방지
      if (attempts >= roundOrder.length) {
        // 한 바퀴 돌았으면 아직 행동하지 않은 플레이어 중 첫 번째 선택
        for (int i = 0; i < roundOrder.length; i++) {
          if (!playersWhoPlayed.contains(roundOrder[i].id) && roundOrder[i].isAlive) {
            currentPlayerIndex = i;
            break;
          }
        }
        break;
      }
    } while (playersWhoPlayed.contains(roundOrder[currentPlayerIndex].id) || 
             !roundOrder[currentPlayerIndex].isAlive);
    
    // 다음 플레이어의 턴으로 전환 (월남 카드는 숨김)
    if (vietnamCard != null) {
      vietnamCard!.isRevealed = false;
    }
    state = GameState.betting;
  }
  
  bool _hasAlivePlayers() {
    return roundOrder.any((player) => player.isAlive && player.coins >= GameConstants.minBet);
  }
  
  void _endRound() {
    state = GameState.finished;
    isCurrentPlayerTurn = false;
  }

  // 현재 플레이어 정보 가져오기
  Player? getCurrentPlayer() {
    if (roundOrder.isEmpty || currentPlayerIndex >= roundOrder.length) {
      return null;
    }
    return roundOrder[currentPlayerIndex];
  }
  
  // 현재 플레이어가 특정 플레이어인지 확인
  bool isPlayerTurn(String playerId) {
    Player? currentPlayer = getCurrentPlayer();
    return currentPlayer?.id == playerId && isCurrentPlayerTurn;
  }

  void nextRound() {
    currentRound++;
    startNewRound();
  }

  bool isGameOver() {
    int alivePlayers = players.where((player) => 
        player.coins >= GameConstants.minBet).length;
    return alivePlayers < GameConstants.minPlayers;
  }

  Player? getOverallWinner() {
    if (!isGameOver()) return null;
    
    Player? richestPlayer;
    int maxCoins = 0;
    
    for (Player player in players) {
      if (player.coins > maxCoins) {
        maxCoins = player.coins;
        richestPlayer = player;
      }
    }
    
    return richestPlayer;
  }

  List<Player> getAlivePlayers() {
    return players.where((player) => player.isAlive).toList();
  }

  List<Player> getPlayersWithMoney() {
    return players.where((player) => player.coins >= GameConstants.minBet).toList();
  }

  Map<String, dynamic> getGameStatus() {
    return {
      'round': currentRound,
      'state': state,
      'totalPot': totalPot,
      'playersCount': players.length,
      'alivePlayersCount': getAlivePlayers().length,
      'vietnamCardRevealed': vietnamCard?.isRevealed ?? false,
      'canStartGame': canStartGame(),
      'isGameOver': isGameOver(),
    };
  }

  void reset() {
    players.clear();
    deck.reset();
    vietnamCard = null;
    playerVietnamCards.clear();
    state = GameState.waiting;
    currentRound = 1;
    totalPot = 0;
    winner = null;
  }
} 