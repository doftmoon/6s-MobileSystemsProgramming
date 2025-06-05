import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  
  ConnectivityService() {
    // Initial check
    _checkConnectivity();
    
    // Subscribe to connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _checkConnectivity();
    });
  }
  
  Future<void> _checkConnectivity() async {
    try {
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      final bool isConnected = (result != ConnectivityResult.none);
      _connectionStatusController.add(isConnected);
    } catch (e) {
      _connectionStatusController.add(false);
    }
  }
  
  Future<bool> isConnected() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  void dispose() {
    _connectionStatusController.close();
  }
} 