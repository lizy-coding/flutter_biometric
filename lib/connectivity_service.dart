import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isNetworkAvailable() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> isBluetoothAvailable() async {
    try {
      // First check if Bluetooth is supported on device
      if (!await FlutterBluePlus.isSupported) {
        debugPrint('Bluetooth not supported on this device');
        return false;
      }
      
      // Try to initialize Bluetooth
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        debugPrint('Could not turn on Bluetooth: $e');
        // Continue checking anyway
      }
      
      // Check Bluetooth state with timeout
      BluetoothAdapterState state;
      try {
        state = await FlutterBluePlus.adapterState.first.timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint('Bluetooth state check timed out');
            return BluetoothAdapterState.unknown;
          },
        );
      } catch (e) {
        debugPrint('Error getting Bluetooth state: $e');
        return false;
      }
      
      debugPrint('Current Bluetooth state: $state');
      return state == BluetoothAdapterState.on;
    } catch (e) {
      debugPrint('Bluetooth check error: $e');
      return false;
    }
  }
}
