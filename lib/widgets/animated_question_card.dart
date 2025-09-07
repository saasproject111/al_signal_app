import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedQuestionCard extends StatefulWidget {
  final String questionText;
  final List<String> options;
  final int? selectedAnswer;
  final int? correctAnswer;
  final bool showResults;
  final Function(int) onAnswerSelected;
  final int questionIndex;
  
  const AnimatedQuestionCard({
    super.key,
    required this.questionText,
    required this.options,
    this.selectedAnswer,
    this.correctAnswer,
    required this.showResults,
    required this.onAnswerSelected,
    required this.questionIndex,
  });

  @override
  State<AnimatedQuestionCard> createState() => _AnimatedQuestionCardState();
}

class _AnimatedQuestionCardState extends State<AnimatedQuestionCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.questionIndex * 100)),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // تأخير الأنيميشن حسب ترتيب السؤال
    Future.delayed(Duration(milliseconds: widget.questionIndex * 150), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startPulse() {
    _pulseController.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                          Colors.teal.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // عنوان السؤال مع أنيميشن
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.withOpacity(0.3),
                                  Colors.cyan.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.tealAccent.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.tealAccent,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.tealAccent.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${widget.questionIndex + 1}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.questionText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // خيارات الإجابة
                          ...List.generate(widget.options.length, (optionIndex) {
                            return _buildOptionTile(optionIndex);
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionTile(int optionIndex) {
    final bool isSelected = widget.selectedAnswer == optionIndex;
    final bool isCorrect = widget.correctAnswer == optionIndex;
    final bool isWrong = widget.showResults && 
                        isSelected && 
                        widget.selectedAnswer != widget.correctAnswer;

    Color backgroundColor = Colors.black.withOpacity(0.3);
    Color borderColor = Colors.white.withOpacity(0.3);
    IconData? trailingIcon;
    Color? iconColor;

    if (widget.showResults) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.3);
        borderColor = Colors.greenAccent;
        trailingIcon = Icons.check_circle;
        iconColor = Colors.greenAccent;
      } else if (isWrong) {
        backgroundColor = Colors.red.withOpacity(0.3);
        borderColor = Colors.redAccent;
        trailingIcon = Icons.cancel;
        iconColor = Colors.redAccent;
      }
    } else if (isSelected) {
      backgroundColor = Colors.teal.withOpacity(0.4);
      borderColor = Colors.tealAccent;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isSelected && !widget.showResults
          ? [
              BoxShadow(
                color: Colors.tealAccent.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ]
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: widget.showResults 
            ? null 
            : () {
                widget.onAnswerSelected(optionIndex);
                _startPulse();
              },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // رقم الخيار
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Colors.tealAccent 
                      : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + optionIndex), // A, B, C, D
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // نص الخيار
                Expanded(
                  child: Text(
                    widget.options[optionIndex],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // أيقونة النتيجة
                if (trailingIcon != null)
                  Icon(
                    trailingIcon,
                    color: iconColor,
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}