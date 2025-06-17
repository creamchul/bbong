import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'single_game_screen.dart';
import '../widgets/card_widget.dart';
import '../models/card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _cardController;
  late Animation<double> _titleAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutBack,
    ));

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));

    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isWebOrTablet = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF2C2C2C),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.all(isWebOrTablet ? 40.0 : 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isWebOrTablet ? 20 : 10),
                    
                    // 제목 애니메이션
                    AnimatedBuilder(
                      animation: _titleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _titleAnimation.value,
                          child: Opacity(
                            opacity: _titleAnimation.value,
                            child: Column(
                              children: [
                                Text(
                                  AppStrings.appName,
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontSize: isWebOrTablet ? 56 : 40,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.cardBorder,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: isWebOrTablet ? 12 : 8),
                                Text(
                                  'Vietnam Bbong',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: isWebOrTablet ? 20 : 16,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: isWebOrTablet ? 60 : 30),
                    
                    // 카드 데모 애니메이션
                    AnimatedBuilder(
                      animation: _cardAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _cardAnimation.value,
                          child: Opacity(
                            opacity: _cardAnimation.value,
                            child: _buildCardDemo(isWebOrTablet),
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: isWebOrTablet ? 60 : 40),
                    
                    // 게임 모드 선택 버튼들
                    Column(
                      children: [
                        _buildMenuButton(
                          context,
                          title: AppStrings.singlePlay,
                          subtitle: 'AI와 대전하기',
                          icon: Icons.person,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SingleGameScreen(),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildMenuButton(
                          context,
                          title: AppStrings.multiPlay,
                          subtitle: '친구들과 함께 (준비중)',
                          icon: Icons.group,
                          onTap: () {
                            _showComingSoon(context);
                          },
                          enabled: false,
                        ),
                        
                        SizedBox(height: isWebOrTablet ? 40 : 30),
                        
                        _buildRulesButton(context),
                      ],
                    ),
                    
                    SizedBox(height: isWebOrTablet ? 20 : 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardDemo(bool isWebOrTablet) {
    final cardWidth = isWebOrTablet ? 90.0 : 70.0;
    final cardHeight = isWebOrTablet ? 130.0 : 100.0;
    
    return Column(
      children: [
        // 플레이어 카드들을 일자로 정렬
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CardWidget(
              card: GameCard(value: 1, id: 'demo1'),
              isRevealed: true,
              width: cardWidth,
              height: cardHeight,
              showAnimation: false,
            ),
            SizedBox(width: isWebOrTablet ? 20 : 15),
            CardWidget(
              card: GameCard(value: 5, id: 'demo2'),
              isRevealed: true,
              width: cardWidth,
              height: cardHeight,
              showAnimation: false,
            ),
            SizedBox(width: isWebOrTablet ? 20 : 15),
            CardWidget(
              card: GameCard(value: 10, id: 'demo3'),
              isRevealed: true,
              width: cardWidth,
              height: cardHeight,
              showAnimation: false,
            ),
          ],
        ),
        
        SizedBox(height: isWebOrTablet ? 20 : 15),
        
        // 월남 카드를 아래쪽에 배치
        Column(
          children: [
            Text(
              AppStrings.vietnam,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isWebOrTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            CardWidget(
              card: GameCard(value: 5, id: 'vietnam'),
              isRevealed: true,
              width: cardWidth,
              height: cardHeight,
              showAnimation: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final isWebOrTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: isWebOrTablet ? 600 : double.infinity,
      ),
      margin: EdgeInsets.symmetric(horizontal: isWebOrTablet ? 40 : 20),
      child: Material(
        color: enabled ? AppColors.buttonPrimary : AppColors.buttonSecondary,
        borderRadius: BorderRadius.circular(16),
        elevation: enabled ? 8 : 4,
        shadowColor: Colors.black.withOpacity(0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: EdgeInsets.all(isWebOrTablet ? 24 : 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isWebOrTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: isWebOrTablet ? 40 : 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: isWebOrTablet ? 24 : 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isWebOrTablet ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isWebOrTablet ? 6 : 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isWebOrTablet ? 16 : 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: isWebOrTablet ? 24 : 20,
                  color: Colors.white.withOpacity(enabled ? 0.8 : 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRulesButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showRules(context),
      icon: const Icon(
        Icons.help_outline,
        color: AppColors.textSecondary,
      ),
      label: const Text(
        '게임 규칙',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          '준비중',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '멀티플레이 기능은 곧 출시될 예정입니다!',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '확인',
              style: TextStyle(color: AppColors.cardBorder),
            ),
          ),
        ],
      ),
    );
  }

  void _showRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          '월남뽕 게임 규칙',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const SingleChildScrollView(
          child: Text(
            '''1. 플레이어는 2장의 카드를 받습니다.

2. 월남 카드 1장이 공개됩니다.

3. 승리 조건:
   • 월남 카드가 내 카드 사이 숫자면 승리
   • 예: 3, 8을 들고 5가 나오면 승리

4. 묻기:
   • 월남 카드가 내 카드 중 하나와 같으면 묻기
   • 베팅금이 다음 라운드로 이월

5. 패배:
   • 월남 카드가 내 카드 범위 밖이면 패배

6. 죽기:
   • 연속 숫자나 같은 카드면 포기 가능''',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '확인',
              style: TextStyle(color: AppColors.cardBorder),
            ),
          ),
        ],
      ),
    );
  }
} 