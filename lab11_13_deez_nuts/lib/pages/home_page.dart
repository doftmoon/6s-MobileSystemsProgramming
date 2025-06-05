import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../pages/favorites_list_widget.dart';
import '../pages/workers_list_widget.dart';
import '../pages/user_info_screen.dart';
import 'home.dart';
import '../services/firebase_service.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';
import '../services/user_preferences.dart';

class HomePage extends StatefulWidget {
  final FirebaseService firebaseService;

  const HomePage({super.key, required this.firebaseService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageViewController;
  int _selectedIndex = 0;
  UserModel? _currentUser;
  bool _isNotificationsEnabled = true;
  bool _isLoadingConfig = true;
  Color _blockColor = Colors.orange;
  bool _isSyncing = false;
  bool _isOfflineMode = false;
  final ConnectivityService _connectivityService = ConnectivityService();
  final SyncService _syncService = SyncService();

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _checkConnectivity();
    _loadUser();
    _loadRemoteConfig();
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await _connectivityService.isConnected();
    if (mounted) {
      setState(() {
        _isOfflineMode = !isConnected;
      });
    }
  }

  Future<void> _loadUser() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Try to load user from Firebase or cache
        try {
          final user = await widget.firebaseService.getUser(userId);
          if (mounted) {
            setState(() {
              _currentUser = user;
            });
          }
        } catch (e) {
          print('Error loading user from service: $e');
        }
      } else {
        // No current Firebase user, try to load from SharedPreferences
        final cachedUser = await UserPreferences.getUser();
        if (cachedUser != null && mounted) {
          setState(() {
            _currentUser = cachedUser;
            _isOfflineMode = true;
          });
        }
      }
    } catch (e) {
      print('Error in loadUser: $e');

      // Last resort - try to get cached user
      _loadCachedUser();
    }
  }

  Future<void> _loadCachedUser() async {
    try {
      final cachedUser = await UserPreferences.getUser();
      if (cachedUser != null && mounted) {
        setState(() {
          _currentUser = cachedUser;
          _isOfflineMode = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load user: $e')));
      }
    }
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      await _syncService.syncNow();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sync completed')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _loadRemoteConfig() async {
    try {
      final isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        if (mounted) {
          setState(() {
            _isLoadingConfig = false;
          });
        }
        return;
      }

      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 0),
        ),
      );
      await remoteConfig.fetch();
      await remoteConfig.activate();
      if (mounted) {
        setState(() {
          _isNotificationsEnabled = remoteConfig.getBool(
            'is_notif_button_enabled',
          );
          // Parse hex color from Remote Config
          final colorHex = remoteConfig.getString('block_color');
          _blockColor = _parseColor(colorHex);
          _isLoadingConfig = false;
          print('BLOCK_COLOR: block_color = $colorHex');
        });
        print('NOTIFS1: test_notif_enabled = $_isNotificationsEnabled');
      }
    } catch (e) {
      print('Error fetching remote config: $e');
      print('Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _isLoadingConfig = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load remote config: $e')),
        );
      }
    }
  }

  Color _parseColor(String colorHex) {
    try {
      // Remove the '#' if present and parse the hex string
      final hexCode = colorHex.replaceFirst('#', '');
      return Color(
        int.parse('FF$hexCode', radix: 16),
      ); // Add alpha (FF) for opacity
    } catch (e) {
      print('Error parsing color: $e');
      return Colors.orange; // Fallback color
    }
  }

  void _onNotificationsPressed() {
    if (_isLoadingConfig) return;
    print('Notifications button pressed, enabled: $_isNotificationsEnabled');
    if (_isNotificationsEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Notifications enabled')));
    }
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Image.asset('assets/funny1.jpg', fit: BoxFit.cover),
        ),
        title: Text(
          _currentUser != null ? 'Welcome, ${_currentUser!.name}' : 'Home',
        ),
        actions: [
          if (!_isOfflineMode)
            IconButton(
              icon: Icon(Icons.sync),
              onPressed: _isSyncing ? null : _syncData,
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'sign_out') {
                if (_isOfflineMode) {
                  // In offline mode, just clear preferences and restart app
                  UserPreferences.clearUserData().then((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => HomePage(
                              firebaseService: widget.firebaseService,
                            ),
                      ),
                    );
                  });
                } else {
                  FirebaseAuth.instance.signOut();
                }
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Text(
                      'Role: ${_currentUser?.role.toString().split('.').last ?? 'N/A'}',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'sign_out',
                    child: Text(
                      _isOfflineMode ? 'Clear Data & Restart' : 'Sign Out',
                    ),
                  ),
                ],
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color:
                  _isLoadingConfig || _isOfflineMode
                      ? Colors.grey
                      : _isNotificationsEnabled
                      ? null
                      : Colors.black,
            ),
            onPressed:
                (_isLoadingConfig || _isOfflineMode)
                    ? null
                    : _onNotificationsPressed,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              backgroundImage: AssetImage('assets/funny1.jpg'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Main content only - connectivity indicator is now only in workers screen
          Expanded(
            child: PageView(
              controller: _pageViewController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      color: _blockColor,
                      child: const Center(
                        child: Text(
                          'Dynamic Block Color',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isOfflineMode ? null : _loadRemoteConfig,
                      child: const Text('Refresh Config'),
                    ),
                  ],
                ),
                WorkersListWidget(
                  firebaseService: widget.firebaseService,
                  isOfflineMode: _isOfflineMode,
                ),
                FavoritesListWidget(firebaseService: widget.firebaseService),
                UserInfoScreen(firebaseService: widget.firebaseService),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 10.0,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _pageViewController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home_outlined, color: Colors.grey),
            activeIcon: Icon(
              Icons.home_outlined,
              color: Colors.deepOrangeAccent,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Workers',
            icon: Icon(Icons.work_outline, color: Colors.grey),
            activeIcon: Icon(
              Icons.work_outline,
              color: Colors.deepOrangeAccent,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Favorites',
            icon: Icon(Icons.favorite_border, color: Colors.grey),
            activeIcon: Icon(
              Icons.favorite_border,
              color: Colors.deepOrangeAccent,
            ),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person_outline, color: Colors.grey),
            activeIcon: Icon(
              Icons.person_outline,
              color: Colors.deepOrangeAccent,
            ),
          ),
        ],
      ),
    );
  }
}
