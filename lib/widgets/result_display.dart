import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ResultDisplay extends StatefulWidget {
  final GameResult result;
  final String message;
  final int? coinChange;
  final bool show;

  const ResultDisplay({
    super.key,
    required this.result,
    required this.message,
    this.coinChange,
    this.show = true,
  });

  @override
  State<ResultDisplay> createState() => _ResultDisplayState();
}

class _ResultDisplayState extends State<ResultDisplay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    if (widget.show) {
      _showResult();
    }
  }

  @override
  void didUpdateWidget(ResultDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _showResult();
      } else {
        _hideResult();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _showResult() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scaleController.forward();
    });
  }

  void _hideResult() {
    _scaleController.reverse();
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.reverse();
    });
  }

  Color _getResultColor() {
    switch (widget.result) {
      case GameResult.win:
        return AppColors.success;
      case GameResult.bury:
        return AppColors.warning;
      case GameResult.lose:
      case GameResult.die:
        return AppColors.danger;
      case GameResult.pending:
        return AppColors.textSecondary;
    }
  }

  IconData _getResultIcon() {
    switch (widget.result) {
      case GameResult.win:
        return Icons.emoji_events;
      case GameResult.bury:
        return Icons.cached;
      case GameResult.lose:
        return Icons.sentiment_dissatisfied;
      case GameResult.die:
        return Icons.close;
      case GameResult.pending:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: _getResultColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getResultColor(),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getResultColor().withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 결과 아이콘
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getResultColor().withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getResultIcon(),
                      size: 40,
                      color: _getResultColor(),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 결과 메시지
                  Text(
                    widget.message,
                    style: TextStyle(
                      color: _getResultColor(),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // 코인 변화량 표시
                  if (widget.coinChange != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.coinChange! > 0 
                              ? Icons.arrow_upward 
                              : Icons.arrow_downward,
                          color: widget.coinChange! > 0 
                              ? AppColors.success 
                              : AppColors.danger,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.coinChange!.abs()} ${AppStrings.coins}',
                          style: TextStyle(
                            color: widget.coinChange! > 0 
                                ? AppColors.success 
                                : AppColors.danger,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class FloatingResultText extends StatefulWidget {
  final String text;
  final Color color;
  final bool show;
  final Duration duration;

  const FloatingResultText({
    super.key,
    required this.text,
    required this.color,
    this.show = true,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<FloatingResultText> createState() => _FloatingResultTextState();
}

class _FloatingResultTextState extends State<FloatingResultText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(FloatingResultText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.reset();
        _controller.forward();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              widget.text,
              style: TextStyle(
                color: widget.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class WinStreakDisplay extends StatefulWidget {
  final int streak;
  final bool show;

  const WinStreakDisplay({
    super.key,
    required this.streak,
    this.show = true,
  });

  @override
  State<WinStreakDisplay> createState() => _WinStreakDisplayState();
}

class _WinStreakDisplayState extends State<WinStreakDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));

    if (widget.show && widget.streak > 1) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(WinStreakDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streak != oldWidget.streak || widget.show != oldWidget.show) {
      if (widget.show && widget.streak > 1) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show || widget.streak <= 1) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.streak} 연승!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 