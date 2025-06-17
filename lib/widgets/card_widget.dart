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
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.cardBorder,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
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
          );
        },
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
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
          children: [
            Icon(
              Icons.casino,
              size: widget.width * 0.4,
              color: AppColors.cardBorder.withOpacity(0.7),
            ),
            const SizedBox(height: 4),
            Text(
              '월남뽕',
              style: TextStyle(
                color: AppColors.cardBorder.withOpacity(0.7),
                fontSize: widget.width * 0.12,
                fontWeight: FontWeight.bold,
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
        color: AppColors.cardFace,
        child: const Center(
          child: Icon(Icons.error, color: Colors.red),
        ),
      );
    }

    return Container(
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
          // 배경 패턴 (선택사항)
          _buildCardPattern(),
          
          // 숫자 레이어
          Column(
            children: [
              // 상단 숫자
              Container(
                height: widget.height * 0.25,
                alignment: Alignment.topLeft,
                padding: EdgeInsets.all(widget.width * 0.08),
                child: _buildNumberWithShadow(
                  widget.card!.value.toString(),
                  fontSize: widget.width * 0.18,
                ),
              ),
              // 중앙 큰 숫자
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: widget.width * 0.1),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: _buildNumberWithShadow(
                      widget.card!.value.toString(),
                      fontSize: widget.width * 0.45,
                      isMain: true,
                    ),
                  ),
                ),
              ),
              // 하단 숫자 (뒤집힌)
              Container(
                height: widget.height * 0.25,
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(widget.width * 0.08),
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
            shadows: [
              Shadow(
                offset: const Offset(2, 2),
                blurRadius: 3,
                color: Colors.black.withOpacity(0.5),
              ),
              Shadow(
                offset: const Offset(-1, -1),
                blurRadius: 1,
                color: Colors.white.withOpacity(0.8),
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