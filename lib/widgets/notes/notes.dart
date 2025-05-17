import 'package:boom_solutions_invoice/final/controller/dashbord_Controller.dart';
import 'package:boom_solutions_invoice/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

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
    final random = Random();
    final quotes = getInspirationalQuotes(context);
    return quotes[random.nextInt(quotes.length)];
  }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              S.of(context)!.notes,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    fontSize: 18,
                  ),
            ),
          ),
          
          Expanded(
            child: NotificationListener<OverscrollNotification>(
              // Prevent parent widget from scrolling when this list is handling scrolling
              onNotification: (notification) {
                if (notification.metrics.axisDirection == AxisDirection.down && 
                    notification.overscroll < 0 &&
                    scrollController?.position.pixels == 0) {
                  // At top edge and trying to scroll up - let parent handle it
                  return false;
                }
                // Prevent scroll propagation in other cases
                return true;
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (controller.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
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
                            S.of(context)!.noNotesYet,
                            style: TextStyle(
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"${getRandomQuote(context)}"',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Notes list with proper scroll physics
                  return ListView.separated(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                    ),
                    itemCount: controller.notes.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.notes.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '"${getRandomQuote(context)}"',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 12,
                          ),
                          leading: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: controller.getPriorityColor(note['priority']),
                            ),
                          ),
                          title: Text(
                            note['title'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: Text(
                            note['message'],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 14,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            note['priority_text'],
                            style: TextStyle(
                              color: controller.getPriorityColor(note['priority']),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}