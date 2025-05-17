import 'package:boom_solutions_invoice/screens/visitsScreens/CheckInScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart' hide TextDirection; // Hide TextDirection from intl to avoid conflict
import 'package:boom_solutions_invoice/generated/l10n.dart';
import 'dart:ui' as ui; // Import dart:ui to explicitly use ui.TextDirection

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: S.of(context).partner_visits,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blueGrey[800],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
      ),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const VisitsScreen(),
    );
  }
}

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  bool isLoading = true;
  Map<String, dynamic> visitData = {};
  String errorMessage = '';
  List<dynamic> filteredVisits = [];
  String sortOrder = '';
  DateTime? selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (sortOrder.isEmpty) {
      sortOrder = S.of(context).newest_first;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVisits();
  }

  Future<void> fetchVisits() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    const String baseUrl = 'https://onix.boom-solutions.co/';
    const String apiToken = 'gln5EU3jkGwBy7GZWnSpm9N7EffslYS5';
    final int partnerId = Get.arguments['partnerId'];
    final String endpoint = '/api/v1/partners/$partnerId/visits';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint?api_token=$apiToken'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          visitData = data;
          filteredVisits = List.from(visitData['visits'] ?? []);
          sortAndFilterVisits();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = '${S.of(context).failed_to_load_visits}: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '${S.of(context).error_fetching_visits}: $e';
        isLoading = false;
      });
    }
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMM d, yyyy HH:mm').format(date);
  }
  void sortAndFilterVisits() {
    List<dynamic> tempVisits = List.from(visitData['visits'] ?? []);
    // Filter by selected date
    if (selectedDate != null) {
      tempVisits = tempVisits.where((visit) {
        final visitDate = DateTime.parse(visit['visit_date']);
        return visitDate.year == selectedDate!.year &&
            visitDate.month == selectedDate!.month &&
            visitDate.day == selectedDate!.day;
      }).toList();
    }
    // Sort based on sortOrder
    tempVisits.sort((a, b) {
      final dateA = DateTime.parse(a['visit_date']);
      final dateB = DateTime.parse(b['visit_date']);
      return sortOrder == 'Newest First'
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
    });
    setState(() {
      filteredVisits = tempVisits;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: S.of(context).select_date,
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        sortAndFilterVisits();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(visitData.containsKey('partner')
            ? visitData['partner']['name']
            : S.of(context).partner_details),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchVisits,
            tooltip: S.of(context).refresh,
          ),
          // IconButton(
          //   icon: const Icon(Icons.language),
          //   onPressed: () {
          //     Get.updateLocale(Get.locale?.languageCode == 'ar'
          //         ? const Locale('en', 'US')
          //         : const Locale('ar', 'EG'));
          //   },
          //   tooltip: S.of(context).switch_language,
          // ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(fontSize: 16)))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Schedule Visit Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              Get.to(() => const CheckInScreen(),
                                  arguments: {'partnerId': Get.arguments['partnerId']});
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    S.of(context).schedule_visit,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Visits History Section
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with sort and date filter
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.notes, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          S.of(context).visits_history,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        // Sort Dropdown
                                        DropdownButton<String>(
                                          value: sortOrder.isEmpty ? S.of(context).newest_first : sortOrder,
                                          items: <String>[
                                            S.of(context).newest_first,
                                            S.of(context).oldest_first
                                          ].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              sortOrder = newValue!;
                                              sortAndFilterVisits();
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        // Date Filter Button
                                        IconButton(
                                          icon: const Icon(Icons.calendar_today),
                                          onPressed: () => _selectDate(context),
                                          tooltip: S.of(context).filter_by_date,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (selectedDate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          selectedDate != null
                                              ? '${S.of(context).filtered_by}:  ${formatDate(selectedDate.toString())}'
                                              : '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedDate = null;
                                              sortAndFilterVisits();
                                            });
                                          },
                                          child: const Icon(
                                            Icons.clear,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                filteredVisits.isNotEmpty
                                    ? Stack(
                                        children: [
                                          // Continuous vertical line
                                          Positioned(
                                            left: isRtl ? null : 30,
                                            right: isRtl ? 30 : null,
                                            top: 0,
                                            bottom: 0,
                                            child: CustomPaint(
                                              size: const Size(2, double.infinity),
                                              painter: ContinuousLinePainter(
                                                itemCount: filteredVisits.length,
                                                itemHeight: 80,
                                              ),
                                            ),
                                          ),
                                          // Visit entries
                                          Column(
                                            children: List.generate(
                                              filteredVisits.length,
                                              (index) {
                                                final visit = filteredVisits[index];
                                                return Container(
                                                  height: 80,
                                                  margin: const EdgeInsets.only(bottom: 8),
                                                  child: Row(
                                                    textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      // Dot for each visit
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                          left: isRtl ? 0 : 24,
                                                          right: isRtl ? 24 : 0,
                                                        ),
                                                        child: Center(
                                                          child: Container(
                                                            width: 12,
                                                            height: 12,
                                                            decoration: const BoxDecoration(
                                                              color: Colors.blue,
                                                              shape: BoxShape.circle,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Visit details
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                                          child: Column(
                                                            crossAxisAlignment: isRtl
                                                                ? CrossAxisAlignment.end
                                                                : CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons.calendar_today,
                                                                        size: 16,
                                                                      ),
                                                                      const SizedBox(width: 8),
                                                                      Text(
                                                                        formatDate(visit['visit_date']),
                                                                        style: const TextStyle(fontSize: 14),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    visit['user_name'],
                                                                    style: const TextStyle(fontSize: 12),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                visit['notes'] ?? S.of(context).no_notes,
                                                                style: const TextStyle(fontSize: 12),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                                textAlign: isRtl ? TextAlign.end : TextAlign.start,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        child: Text(
                                          S.of(context).no_visits_available,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// Custom painter for the continuous vertical line
class ContinuousLinePainter extends CustomPainter {
  final int itemCount;
  final double itemHeight;

  ContinuousLinePainter({required this.itemCount, required this.itemHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, itemHeight * itemCount + (itemCount - 1) * 8),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}