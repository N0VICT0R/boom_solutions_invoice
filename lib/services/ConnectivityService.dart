// import 'dart:async';
// import 'dart:io';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ConnectivityService extends GetxService {
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
//   var isConnected = true.obs; // Observable for connection status

//   @override
//   void onInit() {
//     super.onInit();
//     // Check initial connectivity
//     checkConnectivity();
//     // Listen for connectivity changes
//     try {
//       _connectivitySubscription =
//           _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
//         _updateConnectionStatus(results);
//       });
//     } catch (e) {
//       print('Error listening to connectivity changes: $e');
//       isConnected.value = false;
//       _showConnectionSnackbar('Connection Error', 'Failed to monitor connectivity.');
//     }
//   }

//   @override
//   void onClose() {
//     // Cancel subscription to avoid memory leaks
//     _connectivitySubscription.cancel();
//     super.onClose();
//   }

//   Future<void> checkConnectivity() async {
//     try {
//       var connectivityResults = await _connectivity.checkConnectivity();
//       await _updateConnectionStatus(connectivityResults);
//     } catch (e) {
//       print('Error checking connectivity: $e');
//       isConnected.value = false;
//       _showConnectionSnackbar('Connection Error', 'Unable to check connectivity.');
//     }
//   }

//   Future<bool> checkGoogleAccess() async {
//     try {
//       bool hasConnection = (await _connectivity.checkConnectivity()).any((result) =>
//           result == ConnectivityResult.wifi ||
//           result == ConnectivityResult.mobile ||
//           result == ConnectivityResult.ethernet);
//       if (!hasConnection) return false;
//       return await _checkInternetAccess();
//     } catch (e) {
//       print('Error checking Google access: $e');
//       return false;
//     }
//   }

//   Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
//     // Check if any connectivity result indicates a connection
//     bool hasConnection = results.any((result) =>
//         result == ConnectivityResult.wifi ||
//         result == ConnectivityResult.mobile ||
//         result == ConnectivityResult.ethernet);

//     if (!hasConnection) {
//       isConnected.value = false;
//       _showConnectionSnackbar('No Internet', 'You are offline. Please check your connection.');
//     } else {
//       // Verify actual internet access
//       bool hasInternet = await _checkInternetAccess();
//       isConnected.value = hasInternet;
//       if (!hasInternet) {
//         _showConnectionSnackbar('No Internet', 'No internet access. Please check your connection.');
//       } else {
//         _showConnectionSnackbar('Connected', 'Back online!', isSuccess: true);
//       }
//     }
//   }

//   Future<bool> _checkInternetAccess() async {
//     try {
//       final result = await InternetAddress.lookup('www.google.com');
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } on SocketException catch (_) {
//       return false;
//     }
//   }

//   void _showConnectionSnackbar(String title, String message, {bool isSuccess = false}) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: isSuccess ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
//       colorText: Colors.white,
//       duration: Duration(seconds: 3),
//       margin: EdgeInsets.all(10),
//       borderRadius: 8,
//       isDismissible: true,
//       // onTap: (snack) {
//       //   Get.toNamed('/webView');
//       // },
//     );
//   }
// }
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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
      print('Error listening to connectivity changes: ');
      isConnected.value = false;
      // _showConnectionSnackbar('Connection Error', 'Failed to monitor connectivity.');
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
      print('Error checking connectivity:');
      isConnected.value = false;
      // _showConnectionSnackbar('Connection Error', 'Unable to check connectivity.');
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
      _showConnectionSnackbar('No Internet', 'You are offline. Please check your connection.');
    } else {
      // Verify actual internet access
      bool hasInternet = await _checkInternetAccess();
      isConnected.value = hasInternet;
      if (!hasInternet) {
        _showConnectionSnackbar('No Internet', 'No internet access. Please check your connection.');
      } else {
        // _showConnectionSnackbar('Connected', 'Back online!', isSuccess: true);
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

  void _showConnectionSnackbar(String title, String message, {bool isSuccess = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isSuccess ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      isDismissible: true,
      // onTap: (snack) {
      //   Get.toNamed('/webView');
      // },
    );
  }
}