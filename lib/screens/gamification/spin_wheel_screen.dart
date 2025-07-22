import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/auth_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../utils/app_theme.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isSpinning = false;
  Map<String, dynamic>? _result;

  final List<Color> _wheelColors = [
    AppTheme.primaryRed,
    AppTheme.accentGold,
    AppTheme.successGreen,
    AppTheme.secondaryBlue,
    AppTheme.warningOrange,
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFE91E63), // Pink
    const Color(0xFF00BCD4), // Cyan
  ];

  final List<String> _prizes = [
    '5 Poin',
    '10 Poin',
    '15 Poin',
    '20 Poin',
    '25 Poin',
    '30 Poin',
    'Kupon',
    'Jackpot!',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spinWheel() async {
    final authProvider = context.read<AuthProvider>();
    final gamificationProvider = context.read<GamificationProvider>();

    if (authProvider.currentUser == null) return;

    setState(() {
      _isSpinning = true;
      _result = null;
    });

    // Start spinning animation
    _controller.reset();
    _controller.forward();

    // Call the spin wheel API
    final success = await gamificationProvider.spinWheel(
      authProvider.currentUser!.id,
    );

    if (success) {
      _result = gamificationProvider.spinWheelResult;
    }

    // Wait for animation to complete
    await _controller.forward();

    setState(() {
      _isSpinning = false;
    });

    if (_result != null) {
      _showResultModal();
    } else {
      _showErrorMessage();
    }
  }

  void _showResultModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                color: AppTheme.accentGold,
                size: 48,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Selamat!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              _result?['reward_message'] ?? 'Anda mendapat hadiah!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.neutralGray600,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Lanjutkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terjadi kesalahan. Silakan coba lagi nanti.'),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin the Wheel'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryRed.withOpacity(0.1),
              AppTheme.accentGold.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Title and Instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'Putar Roda Beruntung',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Spin sekali setiap hari dan menangkan hadiah menarik!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.neutralGray600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Wheel
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Wheel
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _animation.value * 8 * math.pi,
                            child: Container(
                              width: 300,
                              height: 300,
                              child: CustomPaint(
                                painter: WheelPainter(
                                  colors: _wheelColors,
                                  prizes: _prizes,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Center button
                      GestureDetector(
                        onTap: _isSpinning ? null : _spinWheel,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _isSpinning 
                                ? AppTheme.neutralGray400 
                                : AppTheme.primaryRed,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isSpinning ? Icons.hourglass_empty : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),

                      // Pointer
                      Positioned(
                        top: -10,
                        child: Container(
                          width: 0,
                          height: 0,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.transparent,
                                width: 15,
                              ),
                              right: BorderSide(
                                color: Colors.transparent,
                                width: 15,
                              ),
                              bottom: BorderSide(
                                color: AppTheme.neutralGray900,
                                width: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Instructions and rules
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Syarat & Ketentuan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Spin dapat dilakukan sekali setiap 24 jam\n'
                      '• Hadiah yang didapat akan langsung masuk ke akun\n'
                      '• Kupon yang didapat berlaku 30 hari\n'
                      '• Tidak dapat digabungkan dengan promo lain',
                      style: TextStyle(
                        color: AppTheme.neutralGray600,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<Color> colors;
  final List<String> prizes;

  WheelPainter({required this.colors, required this.prizes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint();
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    const int sections = 8;
    const double anglePerSection = 2 * math.pi / sections;

    // Draw sections
    for (int i = 0; i < sections; i++) {
      final startAngle = i * anglePerSection;
      final sweepAngle = anglePerSection;

      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw text
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + math.cos(textAngle) * textRadius;
      final textY = center.dy + math.sin(textAngle) * textRadius;

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + math.pi / 2);

      textPainter.text = TextSpan(
        text: prizes[i % prizes.length],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }

    // Draw border
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    canvas.drawCircle(center, radius, paint);

    // Draw section dividers
    paint.strokeWidth = 2;
    for (int i = 0; i < sections; i++) {
      final angle = i * anglePerSection;
      final x1 = center.dx + math.cos(angle) * radius * 0.3;
      final y1 = center.dy + math.sin(angle) * radius * 0.3;
      final x2 = center.dx + math.cos(angle) * radius;
      final y2 = center.dy + math.sin(angle) * radius;
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}