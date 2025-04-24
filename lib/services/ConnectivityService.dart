import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  var isConnected = true.obs; // Observable for connection status

  @override
  void onInit() {
    super.onInit();
    // Check initial connectivity
    checkConnectivity();
    // Listen for connectivity changes
    try {
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
        _updateConnectionStatus(results);
      });
    } catch (e) {
      print('Error listening to connectivity changes: $e');
      isConnected.value = false;
      if (Get.currentRoute != '/offline') {
        Get.offAllNamed('/offline');
      }
    }
  }

  @override
  void onClose() {
    // Cancel subscription to avoid memory leaks
    _connectivitySubscription.cancel();
    super.onClose();
  }

  Future<void> checkConnectivity() async {
    try {
      var connectivityResults = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(connectivityResults);
    } catch (e) {
      print('Error checking connectivity: $e');
      isConnected.value = false;
      if (Get.currentRoute != '/offline') {
        Get.offAllNamed('/offline');
      }
    }
  }

  Future<bool> checkGoogleAccess() async {
    try {
      bool hasConnection = (await _connectivity.checkConnectivity()).any((result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet);
      if (!hasConnection) return false;
      return await _checkInternetAccess();
    } catch (e) {
      print('Error checking Google access: $e');
      return false;
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    // Check if any connectivity result indicates a connection
    bool hasConnection = results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);

    if (!hasConnection) {
      isConnected.value = false;
      if (Get.currentRoute != '/offline') {
        Get.offAllNamed('/offline'); // Navigate to offline screen
      }
    } else {
      // Verify actual internet access
      bool hasInternet = await _checkInternetAccess();
      isConnected.value = hasInternet;
      if (!hasInternet) {
        if (Get.currentRoute != '/offline') {
          Get.offAllNamed('/offline'); // Navigate to offline screen
        }
      } else if (Get.currentRoute == '/offline') {
        Get.offAllNamed('/dashboard'); // Return to dashboard when reconnected
      }
    }
  }

  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}