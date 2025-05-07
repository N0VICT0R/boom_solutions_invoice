import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;
import 'dart:isolate' show SendPort;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LocationTrackerController extends GetxController with WidgetsBindingObserver {
  static LocationTrackerController get to => Get.find<LocationTrackerController>();
  
  // Singleton pattern
  static final LocationTrackerController _instance = LocationTrackerController._internal();
  factory LocationTrackerController() => _instance;
  LocationTrackerController._internal();

  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;
  Timer? _updateTimer;
  Timer? _permissionCheckTimer;
  final List<Map<String, dynamic>> _locationBatch = [];
  double? _lastSpeed;
  DateTime? _lastUpdateTime;
  LocationData? _lastLocation;
  String? _apiToken;
  String _deviceId = '';
  bool _isSendingBatch = false;
  bool _isForegroundTaskRunning = false;
  Timer? _debounceTimer;

  // Reactive variables for UI
  final Rx<LocationData?> currentLocation = Rx<LocationData?>(null);
  final RxString locationStatus = 'Initializing...'.obs;

  // Configuration
  final int _minUpdateInterval = 5000; // 5 seconds
  final int _maxUpdateInterval = 300000; // 5 minutes
  final double _movementThreshold = 20; // meters
  final int _batchSize = 6;
  final String _apiUrl = 'https://onix.boom-solutions.co/api/v1/user/locations/batch';
  final int _maxRetries = 3;
  final Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _permissionCheckTimer?.cancel();
    _debounceTimer?.cancel();
    dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('App state changed to: $state');
    switch (state) {
      case AppLifecycleState.resumed:
        _startTracking();
        _sendPendingBatches();
        _permissionCheckTimer?.cancel();
        _permissionCheckTimer = Timer.periodic(Duration(seconds: 30), (_) => _checkPermissions());
        break;
      case AppLifecycleState.paused:
        _saveBatchToStorage();
        if (!_isForegroundTaskRunning) {
          _startForegroundTask();
        }
        _permissionCheckTimer?.cancel();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _saveBatchToStorage();
        _permissionCheckTimer?.cancel();
        break;
      default:
        break;
    }
  }

  Future<void> initialize() async {
    debugPrint('Initializing LocationTracker...');
    locationStatus.value = 'Checking location service...';
    
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id') ?? await _generateDeviceId();
    await prefs.setString('device_id', _deviceId);
    debugPrint('Device ID: $_deviceId');

    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      debugPrint('Requesting location service...');
      locationStatus.value = 'Please enable location services';
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        debugPrint('Location service denied');
        locationStatus.value = 'Location service disabled';
        return;
      }
    }

    await _checkPermissions();

    if (Platform.isIOS) {
      debugPrint('Enabling iOS background location updates...');
      try {
        await _location.enableBackgroundMode(enable: true);
      } catch (e) {
        debugPrint('Error enabling iOS background mode: $e');
        locationStatus.value = 'Error enabling background mode';
      }
    }

    if (Platform.isAndroid) {
      debugPrint('Requesting battery optimization exemption...');
      try {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      } catch (e) {
        debugPrint('Error requesting battery optimization exemption: $e');
      }
    }

    await _loadPendingBatches();
    _startTracking();
  }

  Future<void> _checkPermissions() async {
    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied || permission == PermissionStatus.deniedForever) {
      debugPrint('Requesting location permission...');
      locationStatus.value = 'Please grant location permission';
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted && permission != PermissionStatus.grantedLimited) {
        debugPrint('Location permission denied');
        locationStatus.value = 'Location permission denied';
        return;
      }
    }
    locationStatus.value = 'Tracking location';
  }

  void setApiToken(String token) {
    debugPrint('API token set');
    _apiToken = token;
  }

  Future<String> _generateDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String id = 'device_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        id = 'android_${androidInfo.id}_${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        id = 'ios_${iosInfo.identifierForVendor}';
      }
    } catch (e) {
      debugPrint('Error generating device ID: $e');
    }
    
    debugPrint('Generated Device ID: $id');
    return id;
  }

  Future<void> _startForegroundTask() async {
    if (await FlutterForegroundTask.isRunningService) {
      debugPrint('Foreground task already running');
      return;
    }

    debugPrint('Starting foreground task...');
    try {
      await FlutterForegroundTask.startService(
        notificationTitle: 'Location Tracking',
        notificationText: 'Tracking your location in the background',
        callback: startCallback,
      );
      _isForegroundTaskRunning = true;
    } catch (e) {
      debugPrint('Error starting foreground task: $e');
    }
  }

  static void startCallback() {
    debugPrint('Foreground task callback started');
    FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
  }

  void _startTracking() async {
    if (_locationSubscription != null) {
      debugPrint('Tracking already started');
      return;
    }

    PermissionStatus permission = await _location.hasPermission();
    if (permission != PermissionStatus.granted && permission != PermissionStatus.grantedLimited) {
      debugPrint('Location permission not granted, stopping tracking');
      locationStatus.value = 'Location permission denied';
      return;
    }

    debugPrint('Starting location tracking...');
    locationStatus.value = 'Fetching initial location...';
    try {
      final location = await _location.getLocation();
      if (location.latitude != null && location.longitude != null) {
        debugPrint('Initial location: ${location.latitude}, ${location.longitude}');
        _lastLocation = location;
        _lastUpdateTime = DateTime.now();
        currentLocation.value = location;
        debugPrint('UI updated with initial location: ${location.latitude}, ${location.longitude}');
        _addToBatch(location);
        locationStatus.value = 'Tracking location';
      } else {
        locationStatus.value = 'Invalid initial location';
      }
    } catch (e) {
      debugPrint('Error getting initial location: $e');
      locationStatus.value = 'Error fetching location';
      return;
    }

    _locationSubscription = _location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude == null || currentLocation.longitude == null) {
        debugPrint('Invalid location data received');
        locationStatus.value = 'Invalid location data';
        return;
      }

      debugPrint('New location update: ${currentLocation.latitude}, ${currentLocation.longitude}');
      _debounceLocationUpdate(currentLocation);
    }, onError: (e) {
      debugPrint('Location stream error: $e');
      locationStatus.value = 'Location error: $e';
      Future.delayed(Duration(seconds: 5), () {
        if (_locationSubscription == null) {
          _startTracking();
        }
      });
    });
  }

  void _debounceLocationUpdate(LocationData location) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      currentLocation.value = location;
      debugPrint('UI updated with debounced location: ${location.latitude}, ${location.longitude}');
      
      final now = DateTime.now();
      final timeDiff = now.difference(_lastUpdateTime ?? now).inMilliseconds;

      if (_lastLocation != null &&
          _lastLocation!.latitude != null &&
          _lastLocation!.longitude != null &&
          timeDiff > 0) {
        final distance = _calculateDistance(
          _lastLocation!.latitude!,
          _lastLocation!.longitude!,
          location.latitude!,
          location.longitude!,
        );

        debugPrint('Movement: ${distance.toStringAsFixed(2)} meters in ${(timeDiff/1000).toStringAsFixed(2)} seconds');
        
        if (distance > _movementThreshold) {
          _lastSpeed = distance / (timeDiff / 1000);
          debugPrint('Calculated speed: ${_lastSpeed?.toStringAsFixed(2)} m/s');
          _adjustUpdateInterval();
        }
      }

      _lastLocation = location;
      _lastUpdateTime = now;
      _addToBatch(location);
    });
  }

  void _adjustUpdateInterval() {
    _updateTimer?.cancel();

    if (_lastSpeed == null) {
      debugPrint('Setting minimum update interval: $_minUpdateInterval ms');
      _updateTimer = Timer(Duration(milliseconds: _minUpdateInterval), _sendBatch);
      return;
    }

    int interval;
    if (_lastSpeed! > 10) {
      interval = _minUpdateInterval;
      debugPrint('High speed detected (>10 m/s), using min interval');
    } else if (_lastSpeed! > 5) {
      interval = _minUpdateInterval * 2;
      debugPrint('Medium speed detected (>5 m/s), using 2x interval');
    } else if (_lastSpeed! > 2) {
      interval = _minUpdateInterval * 4;
      debugPrint('Low speed detected (>2 m/s), using 4x interval');
    } else {
      interval = _maxUpdateInterval;
      debugPrint('Very slow movement, using max interval');
    }

    debugPrint('Setting update interval to $interval ms');
    _updateTimer = Timer(Duration(milliseconds: interval), _sendBatch);
  }

  void _addToBatch(LocationData location) {
    if (location.latitude == null || location.longitude == null) return;

    final locationData = {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'accuracy': location.accuracy,
    };

    debugPrint('Adding to batch: $locationData');
    _locationBatch.add(locationData);

    if (_locationBatch.length >= _batchSize) {
      debugPrint('Batch reached size $_batchSize, sending...');
      _sendBatch();
    }
  }

  Future<void> _sendBatch() async {
    if (_locationBatch.isEmpty || _apiToken == null || _isSendingBatch) {
      debugPrint('Skipping batch send - empty batch, no token, or already sending');
      return;
    }

    _isSendingBatch = true;
    int retryCount = 0;

    final batchToSend = List<Map<String, dynamic>>.from(_locationBatch);
    final requestBody = {
      'api_token': _apiToken,
      'device_id': _deviceId,
      'locations': batchToSend,
    };

    final jsonBody = jsonEncode(requestBody);
    debugPrint('Preparing to send location batch:');
    debugPrint('API URL: $_apiUrl');
    debugPrint('Headers: {Authorization: Bearer $_apiToken, Content-Type: application/json}');
    debugPrint('Request Body: $jsonBody');
    debugPrint('--- End of batch ---');

    while (retryCount < _maxRetries) {
      try {
        debugPrint('Attempt ${retryCount + 1} of $_maxRetries');
        
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Authorization': 'Bearer $_apiToken',
            'Content-Type': 'application/json',
          },
          body: jsonBody,
        );

        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');

        if (response.statusCode == 200) {
          debugPrint('Batch sent successfully');
          _locationBatch.clear();
          await _clearStoredBatch();
          break;
        } else {
          debugPrint('Batch send failed with status: ${response.statusCode}');
          retryCount++;
        }
      } catch (e) {
        debugPrint('Error sending location batch: $e');
        retryCount++;
      }

      if (retryCount < _maxRetries) {
        final delay = Duration(seconds: 2 * retryCount);
        debugPrint('Retrying in ${delay.inSeconds} seconds...');
        await Future.delayed(delay);
      }
    }

    if (retryCount >= _maxRetries) {
      debugPrint('Max retries reached, saving batch to storage');
      await _saveBatchToStorage();
    }

    _isSendingBatch = false;
  }

  Future<void> _saveBatchToStorage() async {
    if (_locationBatch.isEmpty) {
      debugPrint('No locations to save');
      return;
    }
    
    debugPrint('Saving ${_locationBatch.length} locations to storage');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_location_batch', jsonEncode(_locationBatch));
  }

  Future<void> _loadPendingBatches() async {
    debugPrint('Loading pending batches...');
    final prefs = await SharedPreferences.getInstance();
    final storedBatch = prefs.getString('pending_location_batch');
    
    if (storedBatch != null) {
      try {
        final batch = (jsonDecode(storedBatch) as List).map((item) => 
          Map<String, dynamic>.from(item as Map)).toList();
        debugPrint('Loaded ${batch.length} pending locations');
        _locationBatch.addAll(batch);
      } catch (e) {
        debugPrint('Error loading pending batches: $e');
      }
    } else {
      debugPrint('No pending batches found');
    }
  }

  Future<void> _sendPendingBatches() async {
    if (_locationBatch.isNotEmpty) {
      debugPrint('Sending ${_locationBatch.length} pending locations');
      await _sendBatch();
    } else {
      debugPrint('No pending locations to send');
    }
  }

  Future<void> _clearStoredBatch() async {
    debugPrint('Clearing stored batch');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_location_batch');
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000;
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return r * c;
  }

  void stopTracking() {
    debugPrint('Stopping location tracking');
    _locationSubscription?.cancel();
    _updateTimer?.cancel();
    _permissionCheckTimer?.cancel();
    _debounceTimer?.cancel();
    _locationSubscription = null;
    if (_isForegroundTaskRunning) {
      debugPrint('Stopping foreground task');
      FlutterForegroundTask.stopService();
      _isForegroundTaskRunning = false;
    }
    locationStatus.value = 'Tracking stopped';
    currentLocation.value = null;
  }

  Future<void> dispose() async {
    debugPrint('Disposing LocationTracker');
    await _saveBatchToStorage();
    stopTracking();
    await _sendBatch();
  }
}

class LocationTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('Background task started at $timestamp');
    if (!Get.isRegistered<LocationTrackerController>()) {
      Get.put(LocationTrackerController());
      await Get.find<LocationTrackerController>().initialize();
    }
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    debugPrint('Background task update at $timestamp');
    if (Get.isRegistered<LocationTrackerController>()) {
      await Get.find<LocationTrackerController>()._sendPendingBatches();
    } else {
      Get.put(LocationTrackerController());
      await Get.find<LocationTrackerController>().initialize();
      await Get.find<LocationTrackerController>()._sendPendingBatches();
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isWarmup) async {
    debugPrint('Background task destroyed at $timestamp');
  }

  @override
  void onEvent(DateTime timestamp, SendPort? sendPort) {
    debugPrint('Background task event at $timestamp');
  }

  @override
  void onNotificationPressed() {
    debugPrint('Notification pressed');
  }
}