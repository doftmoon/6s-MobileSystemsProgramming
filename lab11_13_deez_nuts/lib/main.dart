import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lab11_13_deez_nuts/services/user_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/home_page.dart';
import 'pages/sign_in_screen.dart';
import '../services/firebase_service.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _showNotification(message);
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Global instance of sync service to ensure it's initialized once
final SyncService syncService = SyncService();
// Global instance of connectivity service
final ConnectivityService connectivityService = ConnectivityService();
// Global instance of FirebaseService
final FirebaseService firebaseService = FirebaseService();

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title ?? 'New Notification',
    message.notification?.body ?? 'Check this out!',
    platformChannelSpecifics,
    payload: message.data.toString(),
  );
}

Future<void> _setupRemoteConfig() async {
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10), // Reduced for faster testing
        minimumFetchInterval: const Duration(
          seconds: 0,
        ), // Force fetch for testing
      ),
    );
    await remoteConfig.setDefaults({
      'is_like_button_enabled': true,
      'is_notif_button_enabled': true,
      'block_color': '#FF5733', // Default color for the block
    });
    try {
      await remoteConfig.fetch();
      await remoteConfig.activate();
      print(
        'Initial Remote Config fetched: is_notif_button_enabled = ${remoteConfig.getBool('is_notif_button_enabled')}',
      );
      print(
        'Initial Remote Config fetched: block_color = ${remoteConfig.getString('block_color')}',
      );
    } catch (e) {
      print('Failed to fetch Remote Config: $e');
    }
  } catch (e) {
    print('Error setting up Remote Config: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with catch for offline mode
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  // Request notification permission only if Firebase is initialized
  if (firebaseInitialized) {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Initialize Remote Config
    await _setupRemoteConfig();

    // Print FCM token for debugging
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $token');
    } catch (e) {
      print('Error getting FCM token: $e');
    }

    // Subscribe to a topic for testing
    try {
      await FirebaseMessaging.instance.subscribeToTopic('all');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
      _showNotification(message);
    });

    // Handle background notifications
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle initial message
    try {
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        print(
          'Initial message received: ${initialMessage.notification?.title}',
        );
        _showNotification(initialMessage);
      }
    } catch (e) {
      print('Error getting initial message: $e');
    }

    // Handle notification clicks
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked: ${message.notification?.title}');
    });
  }

  // Initialize Sync Service if Firebase is initialized
  if (firebaseInitialized) {
    syncService.init();
  }

  runApp(App(firebaseInitialized: firebaseInitialized));
}

class App extends StatelessWidget {
  final bool firebaseInitialized;

  const App({super.key, required this.firebaseInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Worker App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home:
          firebaseInitialized
              ? _buildAuthStateHandler()
              : _buildOfflineStartScreen(),
    );
  }

  Widget _buildAuthStateHandler() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return HomePage(firebaseService: firebaseService);
        }
        return SignInScreen(firebaseService: firebaseService);
      },
    );
  }

  Widget _buildOfflineStartScreen() {
    return FutureBuilder<bool>(
      future: UserPreferences.isLoginValid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isValidLogin = snapshot.data ?? false;

        if (isValidLogin) {
          // User has valid cached login data
          return HomePage(firebaseService: firebaseService);
        } else {
          // No valid cached login data
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.signal_wifi_off,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Internet Connection',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please connect to the internet to sign in',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Try to restart the app
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => App(firebaseInitialized: false),
                        ),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class ConnectivityStatusWidget extends StatelessWidget {
  const ConnectivityStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: connectivityService.connectionStatus,
      builder: (context, snapshot) {
        final bool isConnected = snapshot.data ?? false;

        return Container(
          padding: const EdgeInsets.all(8.0),
          color: isConnected ? Colors.green : Colors.red,
          child: Text(
            isConnected ? 'Online' : 'Offline - Changes will sync when online',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
