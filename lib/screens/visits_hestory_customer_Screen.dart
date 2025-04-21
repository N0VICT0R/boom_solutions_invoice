import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Partner Visits',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blueGrey[800],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
      ),
      home: const VisitsScreen(),
    );
  }
}

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({Key? key}) : super(key: key);

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  bool isLoading = true;
  Map<String, dynamic> visitData = {};
  String errorMessage = '';
  List<dynamic> filteredVisits = [];
  String sortOrder = 'Newest First'; // Default sort order
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchVisits();
  }

  Future<void> fetchVisits() async {
    setState(() {
      isLoading = true;
    });

    const String baseUrl = 'https://onix.boom-solutions.co/';
    const String apiToken = 'gln5EU3jkGwBy7GZWnSpm9N7EffslYS5';
    const String endpoint = '/api/v1/partners/8/visits';

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
          errorMessage = 'Failed to load visits: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching visits: $e';
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
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(visitData.containsKey('partner')
            ? visitData['partner']['name']
            : 'Partner Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchVisits,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Make Payment Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () {
                              // Handle schedule visit
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('Schedule Visit',
                                      style: TextStyle(fontSize: 16)),
                                  Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Notes Section (Updated with Connected Line, Sort, and Search)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with sort and search
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.notes, size: 20),
                                        SizedBox(width: 8),
                                        Text('Visits History',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        // Sort Dropdown
                                        DropdownButton<String>(
                                          value: sortOrder,
                                          items: <String>[
                                            'Newest First',
                                            'Oldest First'
                                          ].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value,
                                                  style: const TextStyle(
                                                      fontSize: 14)),
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
                                        // Date Search Button
                                        IconButton(
                                          icon: const Icon(Icons.calendar_today),
                                          onPressed: () => _selectDate(context),
                                          tooltip: 'Filter by Date',
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
                                          'Filtered by: ${DateFormat('MMM d, yyyy').format(selectedDate!)}',
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
                                          child: const Icon(Icons.clear,
                                              size: 16, color: Colors.red),
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
                                            left: 25,
                                            top: 0,
                                            bottom: 0,
                                            child: CustomPaint(
                                              size: Size(2,
                                                  double.infinity), // Width of line
                                              painter: ContinuousLinePainter(
                                                itemCount: filteredVisits.length,
                                                itemHeight: 100,
                                              ),
                                            ),
                                          ),
                                          // Visit entries
                                          Column(
                                            children: List.generate(
                                              filteredVisits.length,
                                              (index) {
                                                final visit =
                                                    filteredVisits[index];
                                                return SizedBox(
                                                  height: 100,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      // Dot for each visit
                                                      SizedBox(
                                                        width: 50,
                                                        child: Center(
                                                          child: Container(
                                                            width: 16,
                                                            height: 16,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Colors.blue,
                                                              shape:
                                                                  BoxShape.circle,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Visit details
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                        Icons
                                                                            .calendar_today,
                                                                        size:
                                                                            16),
                                                                    const SizedBox(
                                                                        width:
                                                                            6),
                                                                    Text(
                                                                      formatDate(
                                                                          visit[
                                                                              'visit_date']),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              14),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  visit[
                                                                      'user_name'],
                                                                  style:
                                                                      const TextStyle(
                                                                          fontSize:
                                                                              14),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 6),
                                                            Text(
                                                              visit['notes'],
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                          ],
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
                                    : const Text('No visits available'),
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

    // Draw a single continuous line
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 2, itemHeight * itemCount),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}