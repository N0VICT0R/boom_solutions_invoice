import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer Check-in',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const CheckInScreen(),
    );
  }
}

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({Key? key}) : super(key: key);

  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _isLoading = false;
  bool _isLoadingLocation = true;
  Position? _currentPosition;
  String _notes = "Meeting with purchasing manager";
  String? _errorMessage;
  final TextEditingController _notesController = TextEditingController();
  
  // Update these with your actual values
  final String baseUrl = "https://onix.boom-solutions.co/";
 final String apiToken = GetStorage().read('token') ?? '';  
  @override
  void initState() {
    super.initState();
    _notesController.text = _notes;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them.';
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions permanently denied. Please enable in settings.';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
      print("Location obtained: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _submitCheckIn() async {
    if (_currentPosition == null) {
      setState(() {
        _errorMessage = "Location not available. Please try again.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create request payload
       final int partnerId = Get.arguments['partnerId'];
     
       
      final Map<String, dynamic> payload = {
        "api_token": apiToken,
        "partner_id": partnerId,
        "latitude": _currentPosition!.latitude,
        "longitude": _currentPosition!.longitude,
        "notes": _notesController.text,
      };

      print("Sending payload: ${jsonEncode(payload)}");

      // Make API request
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/partners/check-in'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        
        // Show success dialog instead of navigating to new screen
        if (!mounted) return;
        _showResponseDialog(data);
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      print("Exception occurred: $e");
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showResponseDialog(Map<String, dynamic> response) {
    final visit = response['visit'];
    final bool isSuccess = response['success'] ?? false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isSuccess ? 'Check-in Successful' : 'Check-in Failed',
                style: TextStyle(
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(response['message'] ?? 'No message provided'),
                const SizedBox(height: 16),
                if (visit != null) ...[
                  const Text(
                    'Visit Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Visit ID', '${visit['id']}'),
                  _buildDetailRow('Partner', '${visit['partner_name']}'),
                  _buildDetailRow('Date', '${visit['date']}'),
                  _buildDetailRow('User', '${visit['user_name']}'),
                  _buildDetailRow('Distance', '${visit['distance']} meters'),
                  _buildDetailRow('Location Verified', visit['location_verified'] ? 'Yes' : 'No',
                    visit['location_verified'] ? Colors.green : Colors.red),
                  _buildDetailRow('Max Distance', '${visit['max_allowed_distance']} km'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Customer Check-in'),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCheckInForm(),
    );
  }

  Widget _buildCheckInForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Location Display
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border.all(color: Colors.grey.shade700),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Customer Location',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_isLoadingLocation)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_currentPosition != null) ...[
                  Text('Latitude: ${_currentPosition!.latitude.toStringAsFixed(7)}'),
                  Text('Longitude: ${_currentPosition!.longitude.toStringAsFixed(7)}'),
                ] else ...[
                  const Text('Location not available'),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton(
                      onPressed: _getCurrentLocation,
                      child: const Text('Get Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notes Field
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border.all(color: Colors.grey.shade700),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Visit Notes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter notes here',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          
          const Spacer(),
          
          ElevatedButton(
            onPressed: _submitCheckIn,
            child: const Text('CHECK IN'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}