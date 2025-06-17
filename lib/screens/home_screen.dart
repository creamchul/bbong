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

class _HomeScreenState extends State<HomeScreen> {
  bool _isLayoutComplete = false;

  @override
  void initState() {
    super.initState();
    // 웹 환경에서 안전한 레이아웃을 위해 프레임 렌더링 완료 후 인터랙션 활성화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLayoutComplete = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: _isLayoutComplete ? _buildContent() : _buildLoadingContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.cardBorder),
          ),
          SizedBox(height: 16),
          Text(
            '로딩 중...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Scrollbar(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // 제목 섹션
            _buildTitleSection(),
            
            const SizedBox(height: 40),
            
            // 카드 데모 섹션
            _buildCardDemoSection(),
            
            const SizedBox(height: 40),
            
            // 메뉴 버튼들
            _buildMenuSection(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            AppStrings.appName,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.cardBorder,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Vietnam Bbong',
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardDemoSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDemoCard(1, 'demo1'),
            _buildDemoCard(5, 'demo2'),
            _buildDemoCard(10, 'demo3'),
          ],
        );
      },
    );
  }

  Widget _buildDemoCard(int value, String id) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 80,
        maxHeight: 120,
      ),
      child: CardWidget(
        card: GameCard(value: value, id: id),
        isRevealed: true,
        width: 60,
        height: 90,
        showAnimation: false,
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildSafeMenuButton(
          title: AppStrings.singlePlay,
          subtitle: 'AI와 대전하기',
          icon: Icons.person,
          onTap: _isLayoutComplete ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SingleGameScreen(),
              ),
            );
          } : null,
        ),
        
        const SizedBox(height: 16),
        
        _buildSafeMenuButton(
          title: AppStrings.multiPlay,
          subtitle: '친구들과 함께 (준비중)',
          icon: Icons.group,
          onTap: _isLayoutComplete ? () {
            _showComingSoon();
          } : null,
          enabled: false,
        ),
        
        const SizedBox(height: 24),
        
        if (_isLayoutComplete) _buildRulesButton(),
      ],
    );
  }

  Widget _buildSafeMenuButton({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 400,
        minHeight: 80,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: enabled ? AppColors.buttonPrimary : AppColors.buttonSecondary,
        borderRadius: BorderRadius.circular(16),
        elevation: enabled ? 8 : 4,
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.white.withOpacity(enabled ? 0.8 : 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRulesButton() {
    return TextButton.icon(
      onPressed: () => _showRules(),
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

  void _showComingSoon() {
    if (!mounted) return;
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

  void _showRules() {
    if (!mounted) return;
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