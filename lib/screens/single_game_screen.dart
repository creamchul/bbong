import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/game.dart';
import '../models/player.dart';
import '../models/card.dart';
import '../widgets/card_widget.dart';
import '../utils/constants.dart';
import '../utils/game_logic.dart';

class SingleGameScreen extends StatefulWidget {
  const SingleGameScreen({super.key});

  @override
  State<SingleGameScreen> createState() => _SingleGameScreenState();
}

class _SingleGameScreenState extends State<SingleGameScreen> {
  late Game game;
  late Player humanPlayer;
  late Player aiPlayer;
  
  int currentBet = GameConstants.minBet;
  bool isGameStarted = false;
  String resultMessage = '';
  GameResult? currentResult;
  String turnMessage = '';
  bool isAiThinking = false;
  
  // 선 결정 단계
  bool isFirstPlayerSelection = false;
  Map<String, int> firstPlayerCards = {};
  List<GameCard> availableCards = [];
  int? selectedHumanCard;
  int? selectedAiCard;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    game = Game();
    humanPlayer = Player(
      id: 'human',
      name: AppStrings.you,
      coins: GameConstants.startingCoins,
    );
    aiPlayer = Player(
      id: 'ai',
      name: AppStrings.ai,
      coins: GameConstants.startingCoins,
    );
    
    game.addPlayer(humanPlayer);
    game.addPlayer(aiPlayer);
  }

  void _startNewRound() {
    if (!game.hasSelectedFirstPlayer) {
      // 선을 아직 결정하지 않았으면 선 결정부터
      _determineFirstPlayer();
    } else {
      // 이미 선을 결정했으면 바로 게임 시작
      _actuallyStartRound();
    }
  }
  
  void _determineFirstPlayer() {
    setState(() {
      isFirstPlayerSelection = true;
      turnMessage = '카드를 선택해서 선을 정하세요';
      availableCards = game.prepareFirstPlayerCards();
      selectedHumanCard = null;
      selectedAiCard = null;
    });
  }
  
  void _selectCard(int cardValue, bool isForHuman) {
    setState(() {
      if (isForHuman) {
        selectedHumanCard = cardValue;
        
        // 플레이어가 선택하면 AI도 자동으로 선택
        Timer(const Duration(seconds: 1), () {
          if (!mounted) return;
          
          // AI가 랜덤하게 카드 선택
          List<int> availableValues = availableCards
              .where((card) => card.value != selectedHumanCard)
              .map((card) => card.value)
              .toList();
          
          if (availableValues.isNotEmpty) {
            int aiChoice = availableValues[availableValues.length ~/ 2]; // 중간 값 선택
            _selectCard(aiChoice, false);
          }
        });
      } else {
        selectedAiCard = cardValue;
      }
      
      // 둘 다 선택되면 결과 처리
      if (selectedHumanCard != null && selectedAiCard != null) {
        firstPlayerCards = game.setFirstPlayerCards(selectedHumanCard!, selectedAiCard!);
        game.hasSelectedFirstPlayer = true;
        turnMessage = _getFirstPlayerMessage();
        
        // 3초 후 게임 시작
        Timer(const Duration(seconds: 3), () {
          if (!mounted) return;
          _actuallyStartRound();
        });
      }
    });
  }
  
  String _getFirstPlayerMessage() {
    String message = '카드 뽑기 결과:\n';
    firstPlayerCards.forEach((playerId, cardValue) {
      Player? player = game.getPlayer(playerId);
      if (player != null) {
        message += '${player.name}: $cardValue\n';
      }
    });
    
    int maxValue = firstPlayerCards.values.reduce((a, b) => a > b ? a : b);
    String firstPlayerId = firstPlayerCards.entries
        .firstWhere((entry) => entry.value == maxValue)
        .key;
    Player? firstPlayer = game.getPlayer(firstPlayerId);
    
    message += '\n${firstPlayer?.name ?? '플레이어'}가 선입니다!';
    return message;
  }
  
  void _actuallyStartRound() {
    setState(() {
      isFirstPlayerSelection = false;
      firstPlayerCards = {};
      resultMessage = '';
      currentResult = null;
      game.startNewRound();
      isGameStarted = true;
      
      // 현재 턴 플레이어 확인
      Player? currentPlayer = game.getCurrentPlayer();
      if (currentPlayer != null) {
        turnMessage = '${currentPlayer.name}의 차례입니다';
        
        // AI 턴이면 자동 처리
        if (currentPlayer.id == 'ai') {
          _handleAiTurn();
        }
      }
    });
  }

  void _handleAiTurn() {
    setState(() {
      isAiThinking = true;
      turnMessage = 'AI가 생각 중입니다...';
    });

    // AI 생각 시간 시뮬레이션
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      int aiBet = GameLogic.getAiBet(aiPlayer, game.totalPot);
      
      setState(() {
        isAiThinking = false;
        currentResult = game.processCurrentPlayerTurn(aiBet);
      });
      
      // AI 베팅 후에도 잠시 기다렸다가 결과 표시
      Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            if (aiBet == 0) {
              resultMessage = 'AI가 죽었습니다';
            } else {
              resultMessage = GameLogic.getResultMessage(currentResult!);
            }
            
            _updateTurnMessage();
          });
        }
      });
    });
  }

  void _placeBet() {
    if (game.isPlayerTurn(humanPlayer.id) && currentBet <= humanPlayer.coins) {
      setState(() {
        currentResult = game.processCurrentPlayerTurn(currentBet);
      });
      
      // 베팅 후 잠시 기다렸다가 결과 표시 (월남 카드가 보이도록)
      Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            resultMessage = GameLogic.getResultMessage(currentResult!);
            _updateTurnMessage();
          });
        }
      });
    }
  }

  void _die() {
    if (game.isPlayerTurn(humanPlayer.id)) {
      setState(() {
        currentResult = game.processCurrentPlayerTurn(0); // 0은 죽기
        resultMessage = '당신이 죽었습니다';
        _updateTurnMessage();
      });
    }
  }

  void _updateTurnMessage() {
    if (game.state == GameState.finished) {
      turnMessage = '라운드 종료';
      // 라운드가 끝나면 월남 카드가 계속 보이도록 유지
      if (game.vietnamCard != null) {
        game.vietnamCard!.isRevealed = true;
      }
    } else {
      Player? currentPlayer = game.getCurrentPlayer();
      if (currentPlayer != null) {
        turnMessage = '${currentPlayer.name}의 차례입니다';
        
        // AI 턴이면 자동 처리
        if (currentPlayer.id == 'ai' && !isAiThinking) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _handleAiTurn();
          });
        }
      }
    }
  }

  void _nextRound() {
    if (game.isGameOver()) {
      _showGameOver();
      return;
    }
    
    setState(() {
      currentBet = GameConstants.minBet;
      _startNewRound();
    });
  }

  void _showGameOver() {
    Player? winner = game.getOverallWinner();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          '게임 종료',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          winner?.id == 'human' 
              ? '축하합니다! 승리하셨습니다!' 
              : 'AI가 승리했습니다.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              '홈으로',
              style: TextStyle(color: AppColors.cardBorder),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text(
              '다시 하기',
              style: TextStyle(color: AppColors.cardBorder),
            ),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
      isGameStarted = false;
      resultMessage = '';
      currentResult = null;
      currentBet = GameConstants.minBet;
      turnMessage = '';
      isAiThinking = false;
      isFirstPlayerSelection = false;
      firstPlayerCards = {};
      availableCards = [];
      selectedHumanCard = null;
      selectedAiCard = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWebOrTablet = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.appName} - ${AppStrings.singlePlay}'),
        actions: [
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isWebOrTablet ? 24.0 : 16.0),
          child: Column(
            children: [
              // 게임 정보 표시
              _buildGameInfo(),
              
              SizedBox(height: isWebOrTablet ? 20 : 15),
              
              // 턴 정보 또는 선 결정 정보
              if (turnMessage.isNotEmpty) 
                isFirstPlayerSelection ? _buildFirstPlayerInfo() : _buildTurnInfo(),
              
              SizedBox(height: isWebOrTablet ? 30 : 20),
              
              // AI 플레이어 영역
              _buildPlayerArea(aiPlayer, isAI: true, isWebOrTablet: isWebOrTablet),
              
              SizedBox(height: isWebOrTablet ? 40 : 30),
              
              // 월남 카드 영역
              _buildVietnamCardArea(isWebOrTablet),
              
              SizedBox(height: isWebOrTablet ? 40 : 30),
              
              // 인간 플레이어 영역
              _buildPlayerArea(humanPlayer, isAI: false, isWebOrTablet: isWebOrTablet),
              
              SizedBox(height: isWebOrTablet ? 30 : 20),
              
              // 결과 표시
              if (resultMessage.isNotEmpty) _buildResultDisplay(),
              
              SizedBox(height: isWebOrTablet ? 40 : 30),
              
              // 게임 컨트롤 버튼들
              _buildGameControls(),
              
              SizedBox(height: isWebOrTablet ? 20 : 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              const Text(
                '라운드',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                '${game.currentRound}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Text(
                '판돈',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                '${game.totalPot}',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTurnInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.buttonPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.buttonPrimary),
      ),
      child: Text(
        turnMessage,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildFirstPlayerInfo() {
    final isWebOrTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      child: Column(
        children: [
          Text(
            '선 결정중',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            turnMessage,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          // 카드 선택이 필요한 경우에만 표시
          if (availableCards.isNotEmpty && (selectedHumanCard == null || selectedAiCard == null)) ...[
            const SizedBox(height: 16),
            Text(
              selectedHumanCard == null ? '당신의 카드를 선택하세요' : 'AI 카드 자동 선택 중...',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // 카드 선택 영역
            if (selectedHumanCard == null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableCards.asMap().entries.map((entry) {
                  int index = entry.key;
                  GameCard card = entry.value;
                  return GestureDetector(
                    onTap: () => _selectCard(card.value, true),
                    child: Container(
                      width: isWebOrTablet ? 60 : 50,
                      height: isWebOrTablet ? 80 : 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          CardWidget(
                            card: card,
                            isRevealed: false, // 뒷면만 보이게
                            width: isWebOrTablet ? 60 : 50,
                            height: isWebOrTablet ? 80 : 70,
                          ),
                          // 카드 번호 표시 (1, 2, 3...)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.cardBorder,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isWebOrTablet ? 10 : 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
          
          // 선택 결과 표시
          if (selectedHumanCard != null && selectedAiCard != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('당신', style: TextStyle(color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('$selectedHumanCard', style: const TextStyle(color: AppColors.warning, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('AI', style: TextStyle(color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('$selectedAiCard', style: const TextStyle(color: AppColors.warning, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerArea(Player player, {required bool isAI, required bool isWebOrTablet}) {
    final cardWidth = isWebOrTablet ? 90.0 : 70.0;
    final cardHeight = isWebOrTablet ? 130.0 : 100.0;
    final isCurrentPlayer = game.getCurrentPlayer()?.id == player.id;
    
    return Container(
      padding: EdgeInsets.all(isWebOrTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: isCurrentPlayer 
            ? AppColors.cardBorder.withOpacity(0.1)
            : AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer 
              ? AppColors.cardBorder
              : (player.isAlive ? AppColors.success : AppColors.danger),
          width: isCurrentPlayer ? 3 : 2,
        ),
      ),
      child: Column(
        children: [
          // 플레이어 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    player.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isWebOrTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isCurrentPlayer) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.play_arrow,
                      color: AppColors.cardBorder,
                      size: isWebOrTablet ? 24 : 20,
                    ),
                  ],
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${AppStrings.coins}: ${player.coins}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isWebOrTablet ? 16 : 14,
                    ),
                  ),
                  if (player.bet > 0)
                    Text(
                      '${AppStrings.bet}: ${player.bet}',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: isWebOrTablet ? 16 : 14,
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: isWebOrTablet ? 20 : 16),
          
          // 카드 표시
          if (isGameStarted && player.hand.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CardWidget(
                  card: player.hand[0],
                  isRevealed: !isAI || (game.vietnamCard?.isRevealed == true),
                  width: cardWidth,
                  height: cardHeight,
                ),
                SizedBox(width: isWebOrTablet ? 20 : 16),
                CardWidget(
                  card: player.hand[1],
                  isRevealed: !isAI || (game.vietnamCard?.isRevealed == true),
                  width: cardWidth,
                  height: cardHeight,
                ),
              ],
            ),
          
          // 상태 표시
          if (!player.isAlive)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppStrings.dieMessage,
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: isWebOrTablet ? 14 : 12,
                ),
              ),
            ),
          
          if (isAI && isAiThinking)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '생각 중...',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: isWebOrTablet ? 14 : 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVietnamCardArea(bool isWebOrTablet) {
    final cardWidth = isWebOrTablet ? 110.0 : 90.0;
    final cardHeight = isWebOrTablet ? 160.0 : 130.0;
    
    // 현재 차례인 플레이어의 월남 카드만 표시
    GameCard? currentVietnamCard = game.vietnamCard;
    bool shouldShow = currentVietnamCard != null && currentVietnamCard.isRevealed;
    
    return Column(
      children: [
        Text(
          AppStrings.vietnam,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isWebOrTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isWebOrTablet ? 20 : 16),
        
        // 현재 월남 카드
        if (shouldShow)
          Column(
            children: [
              Text(
                '현재 월남 카드',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: isWebOrTablet ? 14 : 12,
                ),
              ),
              const SizedBox(height: 8),
              CardWidget(
                card: currentVietnamCard,
                isRevealed: true,
                width: cardWidth,
                height: cardHeight,
              ),
            ],
          )
        else
          // 카드 뒷면 표시
          CardWidget(
            card: null,
            isRevealed: false,
            width: cardWidth,
            height: cardHeight,
          ),
        
        // 사용된 월남 카드들 표시 (작게)
        if (game.playerVietnamCards.isNotEmpty) ...[
          SizedBox(height: isWebOrTablet ? 20 : 16),
          Text(
            '사용된 월남 카드',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isWebOrTablet ? 14 : 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: game.playerVietnamCards.entries.map((entry) {
              String playerId = entry.key;
              GameCard? card = entry.value;
              String playerName = playerId == 'human' ? '당신' : 'AI';
              
              return Column(
                children: [
                  Text(
                    playerName,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isWebOrTablet ? 12 : 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CardWidget(
                    card: card,
                    isRevealed: true,
                    width: cardWidth * 0.6,
                    height: cardHeight * 0.6,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildResultDisplay() {
    Color resultColor;
    switch (currentResult) {
      case GameResult.win:
        resultColor = AppColors.success;
        break;
      case GameResult.bury:
        resultColor = AppColors.warning;
        break;
      case GameResult.lose:
      case GameResult.die:
        resultColor = AppColors.danger;
        break;
      default:
        resultColor = AppColors.textPrimary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: resultColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: resultColor),
      ),
      child: Text(
        resultMessage,
        style: TextStyle(
          color: resultColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGameControls() {
    final isWebOrTablet = MediaQuery.of(context).size.width > 600;
    
    // 선 결정 중일 때는 아무 버튼도 표시하지 않음
    if (isFirstPlayerSelection) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          '잠시만 기다려주세요...',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: isWebOrTablet ? 16 : 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    if (!isGameStarted) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: isWebOrTablet ? 400 : double.infinity,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: isWebOrTablet ? 16 : 12,
            ),
          ),
          onPressed: _startNewRound,
          child: Text(
            '게임 시작',
            style: TextStyle(fontSize: isWebOrTablet ? 18 : 16),
          ),
        ),
      );
    }

    if (game.state == GameState.finished) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: isWebOrTablet ? 400 : double.infinity,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: isWebOrTablet ? 16 : 12,
            ),
          ),
          onPressed: _nextRound,
          child: Text(
            AppStrings.nextRound,
            style: TextStyle(fontSize: isWebOrTablet ? 18 : 16),
          ),
        ),
      );
    }

    // 인간 플레이어 턴일 때만 컨트롤 표시
    if (game.isPlayerTurn(humanPlayer.id) && !isAiThinking) {
      // 베팅 가능한 최대 금액 계산 (판돈보다 높으면 안됨)
      int maxBet = game.totalPot > 0 
          ? math.min(humanPlayer.coins, game.totalPot)
          : humanPlayer.coins;
      
      return Column(
        children: [
          // 베팅 제한 안내
          if (game.totalPot > 0)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.5)),
              ),
              child: Text(
                '최대 베팅: ${game.totalPot}원 (현재 판돈)',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: isWebOrTablet ? 14 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          // 베팅 금액 조절
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: currentBet > GameConstants.minBet
                    ? () {
                        setState(() {
                          currentBet = math.max(GameConstants.minBet, currentBet - 1000);
                        });
                      }
                    : null,
                iconSize: isWebOrTablet ? 32 : 24,
                icon: const Icon(Icons.remove, color: AppColors.textPrimary),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWebOrTablet ? 24 : 20, 
                  vertical: isWebOrTablet ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$currentBet',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: isWebOrTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: currentBet < maxBet
                    ? () {
                        setState(() {
                          currentBet = math.min(maxBet, currentBet + 1000);
                        });
                      }
                    : null,
                iconSize: isWebOrTablet ? 32 : 24,
                icon: const Icon(Icons.add, color: AppColors.textPrimary),
              ),
            ],
          ),
          
          SizedBox(height: isWebOrTablet ? 20 : 16),
          
          // 액션 버튼들
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _die,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    padding: EdgeInsets.symmetric(
                      vertical: isWebOrTablet ? 16 : 12,
                    ),
                  ),
                  child: Text(
                    AppStrings.die,
                    style: TextStyle(fontSize: isWebOrTablet ? 18 : 16),
                  ),
                ),
              ),
              SizedBox(width: isWebOrTablet ? 20 : 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: currentBet <= humanPlayer.coins ? _placeBet : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isWebOrTablet ? 16 : 12,
                    ),
                  ),
                  child: Text(
                    '${AppStrings.bet} ($currentBet)',
                    style: TextStyle(fontSize: isWebOrTablet ? 18 : 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // AI 턴이거나 대기 중일 때
    return Container(
      padding: const EdgeInsets.all(20),
      child: Text(
        isAiThinking ? 'AI가 생각 중입니다...' : '상대방의 차례를 기다리세요',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: isWebOrTablet ? 18 : 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
} 