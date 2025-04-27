// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Customer Check-in',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor: Colors.black,
//         textTheme: const TextTheme(
//           bodyMedium: TextStyle(color: Colors.white),
//           bodyLarge: TextStyle(color: Colors.white),
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.grey[900],
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           contentPadding: const EdgeInsets.all(16),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             elevation: 0,
//           ),
//         ),
//       ),
//       home: const CheckInScreen(),
//     );
//   }
// }

// class CheckInScreen extends StatefulWidget {
//   const CheckInScreen({Key? key}) : super(key: key);

//   @override
//   _CheckInScreenState createState() => _CheckInScreenState();
// }

// class _CheckInScreenState extends State<CheckInScreen> with SingleTickerProviderStateMixin {
//   bool _isLoading = false;
//   bool _isLoadingLocation = true;
//   bool _isLoadingCustomerLocation = true;
//   Position? _currentPosition;
//   Map<String, dynamic>? _customerLocation;
//   double? _distanceToCustomer;
//   String _notes = " ";
//   String? _errorMessage;
//   final TextEditingController _notesController = TextEditingController();
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;

//   final String baseUrl = "https://onix.boom-solutions.co/";
//   final String apiToken = GetStorage().read('token') ?? '';

//   @override
//   void initState() {
//     super.initState();
//     _notesController.text = _notes;
    
//     // Animation setup
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);
    
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
    
//     _getCurrentLocation();
//     _fetchCustomerLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     setState(() {
//       _isLoadingLocation = true;
//       _errorMessage = null;
//     });

//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         setState(() {
//           _errorMessage = 'Location services are disabled. Please enable them.';
//           _isLoadingLocation = false;
//         });
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           setState(() {
//             _errorMessage = 'Location permission denied';
//             _isLoadingLocation = false;
//           });
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         setState(() {
//           _errorMessage = 'Location permissions permanently denied. Please enable in settings.';
//           _isLoadingLocation = false;
//         });
//         return;
//       }

//       Position position = await Geolocator.getCurrentPosition();
//       setState(() {
//         _currentPosition = position;
//         _isLoadingLocation = false;
//       });
//       _calculateDistance();
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error getting location: $e';
//         _isLoadingLocation = false;
//       });
//     }
//   }

//   Future<void> _fetchCustomerLocation() async {
//     setState(() {
//       _isLoadingCustomerLocation = true;
//       _errorMessage = null;
//     });

//     try {
//       final int partnerId = Get.arguments['partnerId'];
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/v1/partners/map?api_token=$apiToken'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         final data = jsonDecode(response.body);

//         if (data == null || data['partners'] == null) {
//           setState(() {
//             _errorMessage = 'Customer location not available in the response.';
//             _customerLocation = {
//               'name': 'Unknown Customer',
//               'latitude': 0.0,
//               'longitude': 0.0,
//             };
//             _isLoadingCustomerLocation = false;
//           });
//           return;
//         }

//         final List<dynamic> partners = data['partners'];
//         final partner = partners.firstWhere(
//           (p) => p['id'] == partnerId,
//           orElse: () => null,
//         );

//         if (partner == null) {
//           setState(() {
//             _errorMessage = 'Customer with ID $partnerId not found.';
//             _customerLocation = {
//               'name': 'Unknown Customer',
//               'latitude': 0.0,
//               'longitude': 0.0,
//             };
//             _isLoadingCustomerLocation = false;
//           });
//           return;
//         }

//         double latitude = double.tryParse(partner['latitude']?.toString() ?? '0.0') ?? 0.0;
//         double longitude = double.tryParse(partner['longitude']?.toString() ?? '0.0') ?? 0.0;
//         String name = partner['name']?.toString() ?? 'Unknown Customer';

//         if (latitude == 0.0 && longitude == 0.0) {
//           setState(() {
//             _errorMessage = 'Customer location data is invalid.';
//             _customerLocation = {
//               'name': name,
//               'latitude': latitude,
//               'longitude': longitude,
//             };
//             _isLoadingCustomerLocation = false;
//           });
//           return;
//         }

//         setState(() {
//           _customerLocation = {
//             'latitude': latitude,
//             'longitude': longitude,
//             'name': name,
//           };
//           _isLoadingCustomerLocation = false;
//         });
//         _calculateDistance();
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to fetch customer location';
//           _customerLocation = {
//             'name': 'Unknown Customer',
//             'latitude': 0.0,
//             'longitude': 0.0,
//           };
//           _isLoadingCustomerLocation = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error fetching customer location';
//         _customerLocation = {
//           'name': 'Unknown Customer',
//           'latitude': 0.0,
//           'longitude': 0.0,
//         };
//         _isLoadingCustomerLocation = false;
//       });
//     }
//   }

//   void _calculateDistance() {
//     if (_currentPosition != null && _customerLocation != null) {
//       if (_customerLocation!['latitude'] == 0.0 && _customerLocation!['longitude'] == 0.0) {
//         return;
//       }

//       double distanceInMeters = Geolocator.distanceBetween(
//         _currentPosition!.latitude,
//         _currentPosition!.longitude,
//         _customerLocation!['latitude'],
//         _customerLocation!['longitude'],
//       );
//       setState(() {
//         _distanceToCustomer = distanceInMeters / 1000; // Convert to kilometers
//       });
//     }
//   }

//   Future<void> _submitCheckIn() async {
//     if (_currentPosition == null) {
//       setState(() {
//         _errorMessage = "Location not available. Please try again.";
//       });
//       return;
//     }

//     if (_distanceToCustomer != null && _distanceToCustomer! > 10) {
//       _showAlertDialog('Too Far Away', 'You need to be closer to the customer (within 10 km) to check in.');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final int partnerId = Get.arguments['partnerId'];
//       final Map<String, dynamic> payload = {
//         "api_token": apiToken,
//         "partner_id": partnerId,
//         "latitude": _currentPosition!.latitude,
//         "longitude": _currentPosition!.longitude,
//         "notes": _notesController.text,
//       };

//       final response = await http.post(
//         Uri.parse('$baseUrl/api/v1/partners/check-in'),
//         headers: {
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(payload),
//       );

//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         final data = jsonDecode(response.body);
//         if (!mounted) return;
//         _showResponseDialog(data);
//       } else {
//         setState(() {
//           _errorMessage = 'Error: ${response.statusCode} - ${response.reasonPhrase}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Network error: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showAlertDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.grey[900],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Text(
//             title,
//             style: const TextStyle(color: Colors.red),
//           ),
//           content: Text(
//             message,
//             style: const TextStyle(color: Colors.white),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showResponseDialog(Map<String, dynamic> response) {
//     final visit = response['visit'];
//     final bool isSuccess = response['success'] ?? false;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.grey[900],
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Row(
//             children: [
//               Icon(
//                 isSuccess ? Icons.check_circle : Icons.error,
//                 color: isSuccess ? Colors.green : Colors.red,
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 isSuccess ? 'Success' : 'Failed',
//                 style: TextStyle(
//                   color: isSuccess ? Colors.green : Colors.red,
//                 ),
//               ),
//             ],
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(response['message'] ?? 'No message provided'),
//                 if (visit != null) ...[
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Visit Details',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 12),
//                   _buildDetailRow('Partner', '${visit['partner_name']}'),
//                   _buildDetailRow('Date', '${visit['date']}'),
//                   _buildDetailRow('User', '${visit['user_name']}'),
//                 ],
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 80,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: valueColor ?? Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Customer Check-in',
//           style: TextStyle(fontWeight: FontWeight.w500),
//         ),
//         backgroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const [
//                   CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'Processing check-in...',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             )
//           : _buildCheckInForm(),
//     );
//   }

//   Widget _buildCheckInForm() {
//     bool isWithinRange = _distanceToCustomer != null && _distanceToCustomer! <= 10;
    
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Customer name
//             if (_customerLocation != null && !_isLoadingCustomerLocation)
//               Text(
//                 _customerLocation!['name'] ?? 'Customer',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
            
//             // Distance visualization
//             Expanded(
//               child: Center(
//                 child: (_isLoadingLocation || _isLoadingCustomerLocation)
//                     ? const CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                       )
//                     : Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               // User icon
//                               AnimatedBuilder(
//                                 animation: _pulseAnimation,
//                                 builder: (context, child) {
//                                   return Transform.scale(
//                                     scale: _pulseAnimation.value,
//                                     child: Container(
//                                       padding: const EdgeInsets.all(12),
//                                       decoration: BoxDecoration(
//                                         color: Colors.blue.withOpacity(0.1),
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: const Icon(
//                                         Icons.delivery_dining,
//                                         color: Colors.blue,
//                                         size: 36,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
                              
//                               // Distance line
//                               Container(
//                                 width: 100,
//                                 height: 3,
//                                 margin: const EdgeInsets.symmetric(horizontal: 12),
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: [
//                                       Colors.blue,
//                                       isWithinRange ? Colors.green : Colors.red,
//                                     ],
//                                   ),
//                                 ),
//                               ),
                              
//                               // Customer icon
//                               Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: (isWithinRange ? Colors.green : Colors.red).withOpacity(0.1),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   Icons.store,
//                                   color: isWithinRange ? Colors.green : Colors.red,
//                                   size: 36,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 24),
                          
//                           // Distance
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[900],
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               _distanceToCustomer != null
//                                   ? '${_distanceToCustomer!.toStringAsFixed(2)} km'
//                                   : 'Calculating distance...',
//                               style: TextStyle(
//                                 color: _distanceToCustomer != null
//                                     ? (isWithinRange ? Colors.green : Colors.red)
//                                     : Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
                          
//                           const SizedBox(height: 16),
                          
//                           // Status message
//                           Text(
//                             isWithinRange 
//                                 ? 'You are within range to check in' 
//                                 : 'You need to be within 10 km of the customer',
//                             style: TextStyle(
//                               color: isWithinRange ? Colors.green : Colors.red,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//               ),
//             ),
            
//             // Notes field
//             Container(
//               margin: const EdgeInsets.only(bottom: 16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[900],
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: TextField(
//                 controller: _notesController,
//                 decoration: const InputDecoration(
//                   hintText: 'Add visit notes...',
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.all(16),
//                 ),
//                 maxLines: 3,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
            
//             // Error message
//             if (_errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: Text(
//                   _errorMessage!,
//                   style: const TextStyle(color: Colors.red, fontSize: 14),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
            
//             // Check-in button
//             ElevatedButton(
//               onPressed: _submitCheckIn,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isWithinRange ? Colors.blue : Colors.grey[700],
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: Text(
//                 'CHECK IN',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: isWithinRange ? Colors.white : Colors.grey[300],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _notesController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }
// }
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Customer Check-in',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
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

class _CheckInScreenState extends State<CheckInScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isLoadingLocation = true;
  bool _isLoadingCustomerLocation = true;
  Position? _currentPosition;
  Map<String, dynamic>? _customerLocation;
  double? _distanceToCustomer;
  String? _errorMessage;
  final TextEditingController _notesController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  final String baseUrl = "https://onix.boom-solutions.co/";
  final String apiToken = GetStorage().read('token') ?? '';
  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _getCurrentLocation();
    _fetchCustomerLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
      _calculateDistance();
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _fetchCustomerLocation() async {
    setState(() {
      _isLoadingCustomerLocation = true;
      _errorMessage = null;
    });

    try {
      final int partnerId = Get.arguments['partnerId'];
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/partners/map?api_token=$apiToken'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final List<dynamic> partners = data['partners'] ?? [];
        final partner = partners.firstWhere(
          (p) => p['id'] == partnerId,
          orElse: () => null,
        );

        if (partner == null) {
          throw 'Customer not found.';
        }

        double latitude = double.tryParse(partner['latitude']?.toString() ?? '0.0') ?? 0.0;
        double longitude = double.tryParse(partner['longitude']?.toString() ?? '0.0') ?? 0.0;
        String name = partner['name']?.toString() ?? 'Unknown Customer';

        setState(() {
          _customerLocation = {
            'latitude': latitude,
            'longitude': longitude,
            'name': name,
          };
          _isLoadingCustomerLocation = false;
        });
        _calculateDistance();
      } else {
        throw 'Failed to fetch customer location: ${response.statusCode}';
      }
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _customerLocation = {'name': 'Unknown Customer', 'latitude': 0.0, 'longitude': 0.0};
        _isLoadingCustomerLocation = false;
      });
    }
  }

  void _calculateDistance() {
    if (_currentPosition != null && _customerLocation != null) {
      if (_customerLocation!['latitude'] == 0.0 && _customerLocation!['longitude'] == 0.0) {
        return;
      }

      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _customerLocation!['latitude'],
        _customerLocation!['longitude'],
      );
      setState(() {
        _distanceToCustomer = distanceInMeters / 1000;
      });
    }
  }

  Future<void> _submitCheckIn() async {
    if (_currentPosition == null) {
      setState(() {
        _errorMessage = "Location not available.";
      });
      return;
    }

    if (_distanceToCustomer != null && _distanceToCustomer! > 10) {
      bool? proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Distance Warning', style: TextStyle(color: Colors.orange)),
          content: const Text(
            'You are more than 10 km away. Proceed with check-in?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Proceed', style: TextStyle(color: Color(0xFF42A5F5))),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final int partnerId = Get.arguments['partnerId'];
      final payload = {
        "api_token": apiToken,
        "partner_id": partnerId,
        "latitude": _currentPosition!.latitude,
        "longitude": _currentPosition!.longitude,
        "notes": _notesController.text,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/partners/check-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        _showResponseDialog(data);
      } else {
        throw 'Error: ${response.statusCode}';
      }
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showResponseDialog(Map<String, dynamic> response) {
    final bool isSuccess = response['success'] ?? false;
    final visit = response['visit'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              isSuccess ? 'Success' : 'Failed',
              style: GoogleFonts.poppins(
                color: isSuccess ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              response['message'] ?? 'No message provided',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            if (visit != null) ...[
              const SizedBox(height: 8),
              Text(
                'Visit Details:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              _buildDetailRow('Partner', visit['partner_name']),
              _buildDetailRow('Date', visit['date']),
              _buildDetailRow('User', visit['user_name']),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: const Color(0xFF42A5F5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF42A5F5)))
            : _buildCheckInForm(),
      ),
    );
  }

  Widget _buildCheckInForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Check-in',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Location Visualization
          Expanded(
            child: FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Center(
                child: (_isLoadingLocation || _isLoadingCustomerLocation)
                    ? const CircularProgressIndicator(color: Color(0xFF42A5F5))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // User Location
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: gradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1976D2).withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 32),
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomPaint(
                            size: const Size(2, 80),
                            painter: GradientDashedLinePainter(gradient: gradient),
                          ),
                          const SizedBox(height: 8),
                          // Customer Location
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: gradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1976D2).withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.store, color: Colors.white, size: 32),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              _distanceToCustomer != null
                                  ? '${_distanceToCustomer!.toStringAsFixed(2)} km'
                                  : 'N/A',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _customerLocation?['name'] ?? 'Unknown Customer',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          // Notes
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Add notes...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white38),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.poppins(color: Colors.white),
                maxLines: 2,
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.poppins(color: Colors.red[400], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Check-in Button
          FadeInUp(
            duration: const Duration(milliseconds: 1000),
            child: _ActionButton(
              label: 'Check In',
              onTap: _submitCheckIn,
              gradient: gradient,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class GradientDashedLinePainter extends CustomPainter {
  final LinearGradient gradient;

  GradientDashedLinePainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 5;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final LinearGradient gradient;

  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.gradient,
  });

  @override
  __ActionButtonState createState() => __ActionButtonState();
}

class __ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1976D2).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}