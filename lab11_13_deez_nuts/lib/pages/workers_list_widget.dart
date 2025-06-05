import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/favorite_item.dart';
import '../models/user.dart';
import '../models/worker.dart';
import '../services/connectivity_service.dart';
import 'create_worker_dialog.dart';
import 'worker_detail_screen.dart';

class WorkersListWidget extends StatefulWidget {
  final FirebaseService firebaseService;
  final bool isOfflineMode;

  const WorkersListWidget({
    super.key, 
    required this.firebaseService,
    this.isOfflineMode = false,
  });

  @override
  State<WorkersListWidget> createState() => _WorkersListWidgetState();
}

class _WorkersListWidgetState extends State<WorkersListWidget> {
  List<Map<String, dynamic>> _workerData = [];
  List<Worker> _workers = [];
  Set<String> _favoritedWorkerIds = {};
  UserModel? _currentUser;
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to view workers')),
          );
        }
        return;
      }

      final user = await widget.firebaseService.getUser(userId);
      final workerData = await widget.firebaseService.getWorkers();
      final favorites = await widget.firebaseService.getFavorites(userId);
      final favoritedIds = favorites.map((item) => item.itemId).toSet();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _workerData = workerData;
          _workers =
              workerData.map((data) => data['worker'] as Worker).toList();
          _favoritedWorkerIds = favoritedIds;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  Future<void> _showCreateWorkerDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CreateWorkerDialog(firebaseService: widget.firebaseService);
      },
    );

    if (result == true && mounted) {
      _loadUserAndData();
    }
  }

  Future<void> _deleteWorker(String workerId, int index) async {
    try {
      // First update the local state to remove the item immediately
      setState(() {
        _workerData.removeAt(index);
        _workers.removeAt(index);
      });
      
      // Then perform the actual delete operation
      await widget.firebaseService.deleteWorker(workerId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker deleted')),
        );
      }
    } catch (e) {
      // If there's an error, reload the data to restore the original state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete worker: $e')),
        );
        _loadUserAndData(); // Reload to get the original state
      }
    }
  }

  Future<void> _addFavorite(Worker worker, String workerId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to favorite workers')),
        );
      }
      return;
    }

    try {
      final newFavorite = FavoriteItem(
        userId: userId,
        itemId: workerId,
        favoritedAt: DateTime.now(),
        itemName: worker.name,
      );
      await widget.firebaseService.createFavorite(newFavorite);
      if (mounted) {
        setState(() {
          _favoritedWorkerIds.add(workerId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${worker.name} added to favorites')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add favorite: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _currentUser?.role == UserRole.admin;
    final isRegularUser = _currentUser?.role == UserRole.regular;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workers'),
        actions: [
          if ((isAdmin ?? false) && !widget.isOfflineMode)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showCreateWorkerDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          // Main workers list content
          Expanded(
            child: _workers.isEmpty
                ? const Center(child: Text('No workers found.'))
                : ListView.builder(
                    itemCount: _workers.length,
                    itemBuilder: (context, index) {
                      final worker = _workers[index];
                      final workerId = _workerData[index]['id'] as String;
                      final isFavorited = isRegularUser == true &&
                          _favoritedWorkerIds.contains(workerId);

                      return Dismissible(
                        key: ValueKey('${workerId}_$index'), // Use a unique key that changes when the list changes
                        direction: (isAdmin == true || isRegularUser == true) && !widget.isOfflineMode
                            ? DismissDirection.startToEnd
                            : DismissDirection.none,
                        background: Container(
                          color: isAdmin == true ? Colors.red : Colors.yellow,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Icon(
                            isAdmin == true ? Icons.delete : Icons.favorite,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (isAdmin == true) {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: Text(
                                      'Are you sure you want to delete ${worker.name}?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else if (isRegularUser == true &&
                              direction == DismissDirection.startToEnd) {
                            if (!isFavorited) {
                              await _addFavorite(worker, workerId);
                            }
                            return false;
                          }
                          return false;
                        },
                        onDismissed: (direction) {
                          if (isAdmin == true) {
                            _deleteWorker(workerId, index);
                          }
                        },
                        child: ListTile(
                          title: Text(worker.name),
                          subtitle: Text(worker.workName),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$${worker.payment.toStringAsFixed(2)}'),
                              if (isFavorited)
                                const Icon(Icons.favorite, color: Colors.red),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkerDetailScreen(
                                  worker: worker,
                                  workerId: workerId,
                                  isAdmin: isAdmin ?? false,
                                  firebaseService: widget.firebaseService,
                                ),
                              ),
                            ).then((_) => _loadUserAndData());
                          },
                        ),
                      );
                    },
                  ),
          ),
          
          // Connectivity status at the bottom of the screen
          Column(
            children: [
              // Connectivity status indicator
              StreamBuilder<bool>(
                stream: _connectivityService.connectionStatus,
                builder: (context, snapshot) {
                  final bool isConnected = snapshot.data ?? false;
                  
                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    color: isConnected ? Colors.green : Colors.red,
                    width: double.infinity,
                    child: Text(
                      isConnected 
                          ? 'Online - Data is syncing in real-time' 
                          : 'Offline - Changes will sync when online',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              
              // Offline mode banner
              if (widget.isOfflineMode)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.orange,
                  width: double.infinity,
                  child: const Text(
                    'You are working in offline mode with cached data',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
