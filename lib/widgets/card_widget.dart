import 'package:flutter/material.dart';
import '../models/card.dart';
import '../utils/constants.dart';

class CardWidget extends StatefulWidget {
  final GameCard? card;
  final bool isRevealed;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool showAnimation;

  const CardWidget({
    super.key,
    this.card,
    this.isRevealed = false,
    this.width = 80,
    this.height = 120,
    this.onTap,
    this.showAnimation = true,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AnimationConstants.cardFlip,
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _isFlipped = widget.isRevealed;
    if (_isFlipped) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealed != oldWidget.isRevealed) {
      _toggleCard();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (!mounted || !widget.showAnimation) return;
    
    if (widget.showAnimation) {
      if (_isFlipped) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
    _isFlipped = !_isFlipped;
  }

  @override
  Widget build(BuildContext context) {
    // 웹 환경에서 안전한 렌더링을 위한 null 검사
    if (!mounted) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: widget.showAnimation ? 
        AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final isShowingFront = _flipAnimation.value < 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value * 3.14159),
              child: SizedBox(
                width: widget.width,
                height: widget.height,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.cardBorder,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: isShowingFront || !widget.isRevealed
                        ? _buildCardBack()
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(3.14159),
                            child: _buildCardFront(),
                          ),
                  ),
                ),
              ),
            );
          },
        ) :
        // 애니메이션이 비활성화된 경우 단순한 정적 카드
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.cardBorder,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: widget.isRevealed ? _buildCardFront() : _buildCardBack(),
            ),
          ),
        ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground,
            Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.casino,
              size: widget.width * 0.4,
              color: AppColors.cardBorder.withOpacity(0.7),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '월남뽕',
                style: TextStyle(
                  color: AppColors.cardBorder.withOpacity(0.7),
                  fontSize: widget.width * 0.12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    if (widget.card == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.cardFace,
        child: const Center(
          child: Icon(Icons.error, color: Colors.red),
        ),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFF8),
            Color(0xFFFFFFF0),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 배경 패턴
          _buildCardPattern(),
          
          // 상단 숫자
          Positioned(
            top: 8,
            left: 8,
            child: _buildNumberWithShadow(
              widget.card!.value.toString(),
              fontSize: widget.width * 0.18,
            ),
          ),
          
          // 중앙 큰 숫자
          Center(
            child: _buildNumberWithShadow(
              widget.card!.value.toString(),
              fontSize: widget.width * 0.45,
              isMain: true,
            ),
          ),
          
          // 하단 숫자 (뒤집힌)
          Positioned(
            bottom: 8,
            right: 8,
            child: Transform.rotate(
              angle: 3.14159,
              child: _buildNumberWithShadow(
                widget.card!.value.toString(),
                fontSize: widget.width * 0.18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberWithShadow(String number, {required double fontSize, bool isMain = false}) {
    final color = _getNumberColor(widget.card!.value);
    
    return Stack(
      children: [
        // 그림자/테두리 효과
        Text(
          number,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = isMain ? 4 : 3
              ..color = Colors.white,
          ),
        ),
        // 메인 텍스트
        Text(
          number,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: color,
            shadows: const [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 3,
                color: Colors.black54,
              ),
              Shadow(
                offset: Offset(-1, -1),
                blurRadius: 1,
                color: Colors.white60,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardPattern() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.1,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _getNumberColor(widget.card!.value).withOpacity(0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Color _getNumberColor(int value) {
    // 화투 스타일 색상 적용 (더 진하고 대비가 높은 색상)
    switch (value) {
      case 1:
      case 10:
        return const Color(0xFFB71C1C); // 진한 빨강
      case 2:
      case 3:
      case 4:
        return const Color(0xFF1A237E); // 진한 파랑
      case 5:
      case 6:
      case 7:
        return const Color(0xFF4A148C); // 진한 보라
      case 8:
      case 9:
        return const Color(0xFF1B5E20); // 진한 초록
      default:
        return const Color(0xFF212121); // 진한 검정
    }
  }
} 