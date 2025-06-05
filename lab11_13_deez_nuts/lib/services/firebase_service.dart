import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lab11_13_deez_nuts/models/favorite_item.dart';
import 'package:lab11_13_deez_nuts/models/user.dart';
import 'package:lab11_13_deez_nuts/models/worker.dart';
import 'package:lab11_13_deez_nuts/services/connectivity_service.dart';
import 'package:lab11_13_deez_nuts/services/database_helper.dart';
import 'package:lab11_13_deez_nuts/services/user_preferences.dart';
import 'package:uuid/uuid.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ConnectivityService _connectivityService = ConnectivityService();
  final Uuid _uuid = Uuid();

  Future<UserModel> getUser(String userId) async {
    try {
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
        if (!doc.exists) {
          throw Exception('User not found');
        }
        final userModel = UserModel.fromJson(doc.data()!);

        // Save user data to SharedPreferences
        await UserPreferences.saveUser(userModel);

        return userModel;
      } else {
        // Try to get user from SharedPreferences
        final cachedUser = await UserPreferences.getUser();
        if (cachedUser != null) {
          return cachedUser;
        }
        throw Exception(
          'Cannot fetch user while offline and no cached data available',
        );
      }
    } catch (e) {
      print('Error getting user: $e');

      // Try to get user from SharedPreferences as a fallback
      final cachedUser = await UserPreferences.getUser();
      if (cachedUser != null) {
        return cachedUser;
      }

      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      await _saveUserToFirestore(userCredential.user);

      // Save auth user data to SharedPreferences
      if (userCredential.user != null) {
        await UserPreferences.saveAuthUser(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Google Sign-In failed: $e');
      return null;
    }
  }

  Future<void> _saveUserToFirestore(User? user) async {
    if (user != null) {
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'lastSignIn': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();

    // Clear cached user data
    await UserPreferences.clearUserData();
  }

  Future<List<Map<String, dynamic>>> getWorkers() async {
    try {
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        // Online: Get from Firestore and update local DB
        final query =
            await FirebaseFirestore.instance.collection('workers').get();
        final workersList =
            query.docs.map((doc) {
              final worker = Worker.fromJson(doc.data());

              // Update local database
              _dbHelper.updateWorker(doc.id, {
                ...doc.data(),
                'syncStatus': 'synced',
              });

              return {'id': doc.id, 'worker': worker};
            }).toList();
        return workersList;
      } else {
        // Offline: Get from local database
        final localWorkers = await _dbHelper.getWorkers();
        return localWorkers.map((worker) {
          final Map<String, dynamic> workerData = {...worker};
          workerData.remove('syncStatus'); // Remove sync status from the data

          return {
            'id': worker['id'] as String,
            'worker': Worker.fromJson(workerData),
          };
        }).toList();
      }
    } catch (e) {
      print('Error fetching workers: $e');
      rethrow;
    }
  }

  Future<void> createWorker(Worker worker) async {
    final workerData = worker.toJson();
    final isConnected = await _connectivityService.isConnected();
    final String tempId = _uuid.v4();

    if (isConnected) {
      try {
        // Online: Create in Firestore
        final docRef = await FirebaseFirestore.instance
            .collection('workers')
            .add(workerData);

        // Store in local DB
        await _dbHelper.insertWorker({
          ...workerData,
          'syncStatus': 'synced',
        }, docRef.id);
      } catch (e) {
        print('Error creating worker online: $e');
        // Store locally with pending status
        await _dbHelper.insertWorker({
          ...workerData,
          'syncStatus': 'pending_upload',
        }, tempId);
        await _dbHelper.addPendingOperation(
          'add',
          'workers',
          null,
          json.encode(workerData),
        );
      }
    } else {
      // Offline: Store locally with pending status
      await _dbHelper.insertWorker({
        ...workerData,
        'syncStatus': 'pending_upload',
      }, tempId);
      await _dbHelper.addPendingOperation(
        'add',
        'workers',
        null,
        json.encode(workerData),
      );
    }
  }

  Future<void> updateWorker(String workerId, Worker worker) async {
    final workerData = worker.toJson();
    final isConnected = await _connectivityService.isConnected();

    if (isConnected) {
      try {
        // Online: Update in Firestore
        await FirebaseFirestore.instance
            .collection('workers')
            .doc(workerId)
            .update(workerData);

        // Update local DB
        await _dbHelper.updateWorker(workerId, {
          ...workerData,
          'syncStatus': 'synced',
        });
      } catch (e) {
        print('Error updating worker online: $e');
        // Update locally with pending status
        await _dbHelper.updateWorker(workerId, {
          ...workerData,
          'syncStatus': 'pending_upload',
        });
        await _dbHelper.addPendingOperation(
          'update',
          'workers',
          workerId,
          json.encode(workerData),
        );
      }
    } else {
      // Offline: Update locally with pending status
      await _dbHelper.updateWorker(workerId, {
        ...workerData,
        'syncStatus': 'pending_upload',
      });
      await _dbHelper.addPendingOperation(
        'update',
        'workers',
        workerId,
        json.encode(workerData),
      );
    }
  }

  Future<void> deleteWorker(String workerId) async {
    final isConnected = await _connectivityService.isConnected();

    if (isConnected) {
      try {
        // Online: Delete from Firestore
        await FirebaseFirestore.instance
            .collection('workers')
            .doc(workerId)
            .delete();

        // Delete from local DB
        await _dbHelper.deleteWorker(workerId);
      } catch (e) {
        print('Error deleting worker online: $e');
        // Mark for deletion
        await _dbHelper.addPendingOperation(
          'delete',
          'workers',
          workerId,
          json.encode({}),
        );
        await _dbHelper.deleteWorker(workerId);
      }
    } else {
      // Offline: Mark for deletion
      await _dbHelper.addPendingOperation(
        'delete',
        'workers',
        workerId,
        json.encode({}),
      );
      await _dbHelper.deleteWorker(workerId);
    }
  }

  Future<List<FavoriteItem>> getFavorites(String userId) async {
    try {
      final isConnected = await _connectivityService.isConnected();

      if (isConnected) {
        // Online: Get from Firestore
        final query =
            await FirebaseFirestore.instance
                .collection('favorites')
                .where('userId', isEqualTo: userId)
                .get();

        final favorites =
            query.docs.map((doc) {
              final favoriteData = doc.data();

              // Update local database
              _dbHelper.insertFavorite({
                ...favoriteData,
                'id': doc.id,
                'syncStatus': 'synced',
              }, doc.id);

              return FavoriteItem.fromJson(favoriteData);
            }).toList();

        return favorites;
      } else {
        // Offline: Get from local database
        final localFavorites = await _dbHelper.getFavorites(userId);
        return localFavorites.map((favorite) {
          final Map<String, dynamic> favoriteData = {...favorite};
          favoriteData.remove('syncStatus'); // Remove sync status
          favoriteData.remove('id'); // Remove id field

          return FavoriteItem.fromJson(favoriteData);
        }).toList();
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      rethrow;
    }
  }

  Future<void> createFavorite(FavoriteItem favorite) async {
    final favoriteData = favorite.toJson();
    final isConnected = await _connectivityService.isConnected();
    final String tempId = _uuid.v4();

    if (isConnected) {
      try {
        // Online: Create in Firestore
        final docRef = await FirebaseFirestore.instance
            .collection('favorites')
            .add(favoriteData);

        // Store in local DB
        await _dbHelper.insertFavorite({
          ...favoriteData,
          'syncStatus': 'synced',
        }, docRef.id);
      } catch (e) {
        print('Error creating favorite online: $e');
        // Store locally with pending status
        await _dbHelper.insertFavorite({
          ...favoriteData,
          'syncStatus': 'pending_upload',
        }, tempId);
        await _dbHelper.addPendingOperation(
          'add',
          'favorites',
          null,
          json.encode(favoriteData),
        );
      }
    } else {
      // Offline: Store locally with pending status
      await _dbHelper.insertFavorite({
        ...favoriteData,
        'syncStatus': 'pending_upload',
      }, tempId);
      await _dbHelper.addPendingOperation(
        'add',
        'favorites',
        null,
        json.encode(favoriteData),
      );
    }
  }

  Future<void> deleteFavorite(String userId, String itemId) async {
    final isConnected = await _connectivityService.isConnected();

    if (isConnected) {
      try {
        // Online: Delete from Firestore
        final query =
            await FirebaseFirestore.instance
                .collection('favorites')
                .where('userId', isEqualTo: userId)
                .where('itemId', isEqualTo: itemId)
                .get();

        for (var doc in query.docs) {
          await doc.reference.delete();
        }

        // Delete from local DB
        await _dbHelper.deleteFavorite(userId, itemId);
      } catch (e) {
        print('Error deleting favorite online: $e');
        // Mark for deletion
        await _dbHelper.addPendingOperation(
          'delete',
          'favorites',
          null, // No specific document ID
          json.encode({'userId': userId, 'itemId': itemId}),
        );
        await _dbHelper.deleteFavorite(userId, itemId);
      }
    } else {
      // Offline: Mark for deletion
      await _dbHelper.addPendingOperation(
        'delete',
        'favorites',
        null, // No specific document ID
        json.encode({'userId': userId, 'itemId': itemId}),
      );
      await _dbHelper.deleteFavorite(userId, itemId);
    }
  }
}
