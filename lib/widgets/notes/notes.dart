import 'dart:async';

import 'package:boom_solutions_invoice/final/controller/dashbord_Controller.dart';
import 'package:boom_solutions_invoice/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class NotesWidget extends StatelessWidget {
  final double height;
  final ScrollController? scrollController;

  const NotesWidget({
    super.key,
    required this.height,
    this.scrollController,
  });

  String getInspirationalQuotes(BuildContext context) {
    return S.of(context)!.inspirationalQuotes;
  }

  String getRandomQuote(BuildContext context) {
    final quotes = getInspirationalQuotes(context).split(';');
    return quotes[math.Random().nextInt(quotes.length)].trim();
  }

  void _showAllNotesDialog(BuildContext context, List<Map<String, dynamic>> notes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: 400,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context)!.addNotes,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: notes.length,
                  separatorBuilder: (context, _) => Divider(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final title = note['title']?.toString() ?? 'No Title';
                    final message = note['message']?.toString() ?? 'No Message';
                    final priority = note['priority'] ?? 0;
                    final controller = Get.find<DashboardController>();
                    
                    return ListTile(
                      title: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: controller.getPriorityColor(priority),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      subtitle: Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context)!.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<DashboardController>();

    return NotificationListener<OverscrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axisDirection == AxisDirection.down &&
            notification.overscroll < 0 &&
            scrollController?.position.pixels == 0) {
          return false;
        }
        return true;
      },
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Text(
            controller.errorMessage.value,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          );
        }

        if (controller.notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context)!.noNotesYet,
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                // Text(
                //   '"${getRandomQuote(context)}"',
                //   style: TextStyle(
                //     color: isDark ? Colors.grey[400] : Colors.grey[600],
                //     fontStyle: FontStyle.italic,
                //     fontSize: 12,
                //   ),
                //   textAlign: TextAlign.center,
                //   maxLines: 3,
                //   overflow: TextOverflow.ellipsis,
                // ),
              ],
            ),
          );
        }

        return Column(
          children: [
            GestureDetector(
              onTap: () => _showAllNotesDialog(context, controller.notes),
              child: AutoFadeText(
                notes: controller.notes,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Text(
            //     '"${getRandomQuote(context)}"',
            //     style: TextStyle(
            //       color: isDark ? Colors.grey[400] : Colors.grey[600],
            //       fontStyle: FontStyle.italic,
            //       fontSize: 12,
            //     ),
            //     textAlign: TextAlign.center,
            //     maxLines: 3,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ),
          ],
        );
      }),
    );
  }
}

class AutoFadeText extends StatefulWidget {
  final List<Map<String, dynamic>> notes;

  const AutoFadeText({
    super.key,
    required this.notes,
  });

  @override
  _AutoFadeTextState createState() => _AutoFadeTextState();
}

class _AutoFadeTextState extends State<AutoFadeText> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late Timer _timer;
  final controller = Get.find<DashboardController>();
  bool _isVisible = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.1), // Slight upward shift
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _startAutoFade();
  }

  void _startAutoFade() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.notes.isEmpty) return;
      final note = widget.notes[_currentIndex];
      final priority = note['priority'] ?? 0;
      final duration = controller.getPriorityColor(priority) == Colors.red ? 6 : 3;

      if (timer.tick % duration == 0) {
        _animationController.forward().then((_) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.notes.length;
            _isVisible = true;
          });
          _animationController.reverse();
        });
      }
    });
  }

  @override
  void didUpdateWidget(AutoFadeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notes.length != oldWidget.notes.length) {
      _timer.cancel();
      _currentIndex = 0;
      _startAutoFade();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (widget.notes.isEmpty) {
      return const SizedBox.shrink();
    }

    final note = widget.notes[_currentIndex];
    final title = note['title']?.toString() ?? 'No Title';
    final message = note['message']?.toString() ?? 'No Message';
    final priority = note['priority'] ?? 0;
    final fullText = '$title: $message';

    final textPainter = TextPainter(
      text: TextSpan(
        text: fullText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 48);
    final isLongText = textPainter.didExceedMaxLines;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.1), // Slide in from bottom
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Text(
        key: ValueKey<int>(_currentIndex), // Unique key for AnimatedSwitcher
        fullText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: isLongText ? 12 : 14,
          color: controller.getPriorityColor(priority),
          fontWeight: FontWeight.w500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}