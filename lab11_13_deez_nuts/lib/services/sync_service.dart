import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab11_13_deez_nuts/services/connectivity_service.dart';
import 'package:lab11_13_deez_nuts/services/database_helper.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  // Start monitoring connectivity changes
  void init() {
    _connectivitySubscription = _connectivityService.connectionStatus.listen((
      isConnected,
    ) {
      if (isConnected && !_isSyncing) {
        syncPendingOperations();
      }
    });
  }

  // Sync all pending operations when connectivity is restored
  Future<void> syncPendingOperations() async {
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final pendingOperations = await _dbHelper.getPendingOperations();

      for (final operation in pendingOperations) {
        await _processPendingOperation(operation);
        await _dbHelper.deletePendingOperation(operation['id'] as int);
      }

      // Download any updates from Firestore
      await _downloadFirestoreUpdates();
    } catch (e) {
      print('Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Process a single pending operation
  Future<void> _processPendingOperation(Map<String, dynamic> operation) async {
    final String operationType = operation['operation'] as String;
    final String collection = operation['collection'] as String;
    final String? documentId = operation['documentId'] as String?;
    final Map<String, dynamic> data = json.decode(operation['data'] as String);

    try {
      switch (operationType) {
        case 'add':
          if (collection == 'workers') {
            final docRef = await _firestore.collection(collection).add(data);
            await _dbHelper.markWorkerSynced(docRef.id);
          } else if (collection == 'favorites') {
            final docRef = await _firestore.collection(collection).add(data);
            await _dbHelper.markFavoriteSynced(docRef.id);
          }
          break;

        case 'update':
          if (documentId != null) {
            await _firestore
                .collection(collection)
                .doc(documentId)
                .update(data);
            if (collection == 'workers') {
              await _dbHelper.markWorkerSynced(documentId);
            } else if (collection == 'favorites') {
              await _dbHelper.markFavoriteSynced(documentId);
            }
          }
          break;

        case 'delete':
          if (documentId != null) {
            await _firestore.collection(collection).doc(documentId).delete();
          }
          break;
      }
    } catch (e) {
      print('Error processing operation: $e');
      // Retry later
    }
  }

  // Download updates from Firestore
  Future<void> _downloadFirestoreUpdates() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Sync workers
      final workersSnapshot = await _firestore.collection('workers').get();
      for (final doc in workersSnapshot.docs) {
        final workerData = doc.data();
        workerData['id'] = doc.id;
        workerData['syncStatus'] = 'synced';

        await _dbHelper.updateWorker(doc.id, workerData);
      }

      // Sync favorites for current user
      final favoritesSnapshot =
          await _firestore
              .collection('favorites')
              .where('userId', isEqualTo: currentUser.uid)
              .get();

      for (final doc in favoritesSnapshot.docs) {
        final favoriteData = doc.data();
        favoriteData['id'] = doc.id;
        favoriteData['syncStatus'] = 'synced';

        await _dbHelper.insertFavorite(favoriteData, doc.id);
      }
    } catch (e) {
      print('Error downloading updates: $e');
    }
  }

  // Force a sync
  Future<void> syncNow() async {
    final isConnected = await _connectivityService.isConnected();
    if (isConnected) {
      await syncPendingOperations();
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
