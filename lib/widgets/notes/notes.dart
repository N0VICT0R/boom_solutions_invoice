import 'package:boom_solutions_invoice/final/controller/dashbord_Controller.dart';
import 'package:boom_solutions_invoice/final/view/homeScreen/dashboard_Getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

// Random quotes list
final List<String> inspirationalQuotes = [
  "Success is not the absence of obstacles, but the courage to push through them.",
  "The only limit to our realization of tomorrow is our doubts of today.",
  "Your time is limited, so don’t waste it living someone else’s life.",
  "The future belongs to those who believe in the beauty of their dreams.",
  "Do what you can, with what you have, where you are.",
  "Every moment is a fresh beginning.",
  "The best way to predict the future is to create it.",
  "Stay hungry, stay foolish.",
  "You miss 100% of the shots you don’t take.",
  "Dream big, work hard, stay focused.",
];

String getRandomQuote() {
  final random = Random();
  return inspirationalQuotes[random.nextInt(inspirationalQuotes.length)];
}

class NotesWidget extends StatelessWidget {
  final double height;
  final ScrollController? scrollController; // Optional for scroll-to-bottom

  const NotesWidget({super.key, required this.height, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<DashboardController>();

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: isDark ? 20 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    fontSize: getResponsiveFontSize(context, 18),
                  ),
            ),
         
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: getResponsiveFontSize(context, 14),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (controller.notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No notes yet',
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            fontStyle: FontStyle.italic,
                            fontSize: getResponsiveFontSize(context, 14),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"${getRandomQuote()}"',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: getResponsiveFontSize(context, 12),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  itemCount: controller.notes.length + 1,
                  itemBuilder: (_, index) {
                    if (index == controller.notes.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '"${getRandomQuote()}"',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontSize: getResponsiveFontSize(context, 12),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                    final note = controller.notes[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      decoration: BoxDecoration(
                        // color: controller.getPriorityColor(note['priority']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 12,
                        ),
                        leading: Container(
                          width: getResponsiveFontSize(context, 10),
                          height: getResponsiveFontSize(context, 10),
                          decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.getPriorityColor(note['priority']),
                          ),
                        ),
                        title: Text(
                          note['title'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: getResponsiveFontSize(context, 16),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        subtitle: Text(
                          note['message'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: getResponsiveFontSize(context, 14),
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          note['priority_text'],
                          style: TextStyle(
                            color: controller.getPriorityColor(note['priority']),
                            fontSize: getResponsiveFontSize(context, 12),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}