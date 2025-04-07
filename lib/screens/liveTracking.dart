// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:get/get.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
//
// // ----------------------- Database Helper -----------------------
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   static Database? _database;
//
//   DatabaseHelper._internal();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     // lazily instantiate the db the first time it is accessed
//     _database = await _initDb();
//     return _database!;
//   }
//
//   Future<Database> _initDb() async {
//     final documentsDirectory = await getApplicationDocumentsDirectory();
//     final path = join(documentsDirectory.path, "locations.db");
//
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (Database db, int version) async {
//         await db.execute('''
//           CREATE TABLE locations (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             latitude REAL,
//             longitude REAL,
//             timestamp TEXT
//           )
//         ''');
//       },
//     );
//   }
//
//   Future<void> insertLocation(LatLng point) async {
//     final db = await database;
//     await db.insert(
//       'locations',
//       {
//         'latitude': point.latitude,
//         'longitude': point.longitude,
//         'timestamp': DateTime.now().toIso8601String(),
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }
//
//   Future<List<Map<String, dynamic>>> getLocations() async {
//     final db = await database;
//     return await db.query('locations', orderBy: "id DESC");
//   }
// }
//
// // ----------------------- Location Controller -----------------------
// class LocationController extends GetxController {
//   var currentPosition = Rxn<LatLng>();
//   var routePoints = <LatLng>[].obs;
//   var isTracking = false.obs;
//   var isPaused = false.obs;
//   var isFollowing = true.obs;
//
//   StreamSubscription<Position>? _positionStream;
//   final DatabaseHelper dbHelper = DatabaseHelper();
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initLocationTracking();
//   }
//
//   @override
//   void onClose() {
//     _positionStream?.cancel();
//     super.onClose();
//   }
//
//   Future<void> _initLocationTracking() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         Get.snackbar("Location Error", "Please enable location services");
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           Get.snackbar("Location Permission", "Permission denied");
//           return;
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         Get.snackbar("Location Permission", "Permission permanently denied",
//             snackPosition: SnackPosition.BOTTOM);
//         return;
//       }
//
//       _startTracking();
//     } catch (e) {
//       Get.snackbar("Error", "Failed to initialize tracking: $e");
//     }
//   }
//
//   void _startTracking() {
//     isTracking.value = true;
//     _positionStream = Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 5,
//         timeLimit: Duration(seconds: 30),
//       ),
//     ).listen(
//       (Position position) {
//         if (!isPaused.value) {
//           final LatLng newPoint = LatLng(position.latitude, position.longitude);
//           currentPosition.value = newPoint;
//           routePoints.add(newPoint);
//           _optimizeRoutePoints();
//           // Save to SQLite database with timestamp
//           dbHelper.insertLocation(newPoint);
//         }
//       },
//       onError: (error) {
//         isTracking.value = false;
//         Get.snackbar("Tracking Error", "Error: $error");
//       },
//     );
//   }
//
//   void _optimizeRoutePoints() {
//     if (routePoints.length > 100) {
//       routePoints.removeRange(0, routePoints.length - 100);
//     }
//   }
//
//   void togglePause() {
//     isPaused.value = !isPaused.value;
//   }
//
//   void resetTracking() {
//     routePoints.clear();
//     isPaused.value = false;
//     isFollowing.value = true;
//   }
// }
//
// // ----------------------- Live Tracking Page -----------------------
// class LiveTrackingPage extends StatelessWidget {
//   LiveTrackingPage({super.key});
//
//   final LocationController controller = Get.put(LocationController());
//   final MapController mapController = MapController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Live Delivery Tracking'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: controller.resetTracking,
//           ),
//           IconButton(
//             icon: const Icon(Icons.history),
//             onPressed: () {
//               Get.to(() => const HistoryScreen());
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             heroTag: "zoomIn",
//             mini: true,
//             backgroundColor: Colors.green,
//             onPressed: () {
//               if (controller.currentPosition.value != null) {
//                 mapController.move(
//                   controller.currentPosition.value!,
//                   17,
//                 );
//               }
//             },
//             child: const Icon(Icons.zoom_in),
//           ),
//           const SizedBox(height: 10),
//           FloatingActionButton(
//             heroTag: "center",
//             backgroundColor: Colors.green,
//             onPressed: () {
//               if (controller.currentPosition.value != null) {
//                 mapController.move(controller.currentPosition.value!, 17);
//               }
//             },
//             child: const Icon(Icons.my_location),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         return Stack(
//           children: [
//             FlutterMap(
//               mapController: mapController,
//               options: MapOptions(
//                 initialCenter: controller.currentPosition.value ??
//                     const LatLng(30.0333, 31.2333),
//                 initialZoom: 16,
//                 minZoom: 5,
//                 maxZoom: 18,
//                 onPositionChanged: (position, hasGesture) {
//                   if (hasGesture) {
//                     controller.isFollowing.value = false;
//                   }
//                 },
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate:
//                       'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                   subdomains: const ['a', 'b', 'c'],
//                   userAgentPackageName: 'com.example.app',
//                   retinaMode: MediaQuery.of(context).platformBrightness ==
//                       Brightness.dark,
//                 ),
//                 PolylineLayer(
//                   polylines: [
//                     if (controller.routePoints.isNotEmpty)
//                       Polyline(
//                         points: controller.routePoints,
//                         strokeWidth: 5,
//                         color: Colors.blue.withOpacity(0.7),
//                         borderStrokeWidth: 2,
//                         borderColor: Colors.blueAccent,
//                       ),
//                   ],
//                 ),
//                 MarkerLayer(
//                   markers: [
//                     if (controller.currentPosition.value != null)
//                       Marker(
//                         point: controller.currentPosition.value!,
//                         width: 60,
//                         height: 60,
//                         child: const _AnimatedDeliveryMarker(),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//             Positioned(
//               top: 10,
//               left: 10,
//               child: Obx(
//                 () => _TrackingStatusChip(
//                   isTracking: controller.isTracking.value,
//                   isPaused: controller.isPaused.value,
//                 ),
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
//
// // ----------------------- Animated Delivery Marker -----------------------
// class _AnimatedDeliveryMarker extends StatelessWidget {
//   const _AnimatedDeliveryMarker();
//
//   @override
//   Widget build(BuildContext context) {
//     return TweenAnimationBuilder(
//       tween: Tween<double>(begin: 0.8, end: 1.0),
//       duration: const Duration(milliseconds: 800),
//       curve: Curves.easeInOut,
//       builder: (context, scale, child) {
//         return Transform.scale(
//           scale: scale as double,
//           child: const Icon(
//             Icons.delivery_dining,
//             color: Colors.red,
//             size: 40,
//             shadows: [
//               Shadow(
//                   color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// // ----------------------- Tracking Status Chip -----------------------
// class _TrackingStatusChip extends StatelessWidget {
//   final bool isTracking;
//   final bool isPaused;
//
//   const _TrackingStatusChip(
//       {required this.isTracking, required this.isPaused});
//
//   @override
//   Widget build(BuildContext context) {
//     return Chip(
//       label: Text(
//         isTracking ? (isPaused ? 'Paused' : 'Tracking') : 'Stopped',
//         style: const TextStyle(color: Colors.white),
//       ),
//       backgroundColor:
//           isTracking ? (isPaused ? Colors.orange : Colors.green) : Colors.red,
//       elevation: 2,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//     );
//   }
// }
//
// // ----------------------- History Screen -----------------------
// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({super.key});
//
//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }
//
// class _HistoryScreenState extends State<HistoryScreen>
//     with SingleTickerProviderStateMixin {
//   List<Map<String, dynamic>> locations = [];
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadLocations();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _controller.forward();
//   }
//
//   Future<void> _loadLocations() async {
//     final data = await DatabaseHelper().getLocations();
//     setState(() {
//       locations = data;
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   String _formatTimestamp(String timestamp) {
//     DateTime dt = DateTime.parse(timestamp);
//     return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.day}/${dt.month}/${dt.year}";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Visited Locations'),
//       ),
//       body: locations.isEmpty
//           ? const Center(child: Text("No location data available."))
//           : ListView.builder(
//               itemCount: locations.length,
//               itemBuilder: (context, index) {
//                 final loc = locations[index];
//                 return FadeTransition(
//                   opacity: _controller,
//                   child: ListTile(
//                     leading: const Icon(Icons.location_on, color: Colors.blue),
//                     title: Text(
//                         "Lat: ${loc['latitude'].toStringAsFixed(4)}, Lng: ${loc['longitude'].toStringAsFixed(4)}"),
//                     subtitle: Text(_formatTimestamp(loc['timestamp'])),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
