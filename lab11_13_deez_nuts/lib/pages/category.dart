import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/favorite_item.dart';
import '../models/user.dart';
import '../models/worker.dart';
import 'worker_detail_screen.dart';
import '../services/firebase_service.dart';

class CategoryDetails extends StatefulWidget {
  final String category;
  final FirebaseService firebaseService;

  const CategoryDetails(
      {super.key, required this.category, required this.firebaseService});

  @override
  State<CategoryDetails> createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  List<Map<String, dynamic>> _workerData = [];
  List<Worker> _workers = [];
  Set<String> _favoritedWorkerIds = {};
  UserModel? _currentUser;
  List<Widget> _categoryList = [];

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

      final filteredWorkerData = workerData.where((data) {
        final worker = data['worker'] as Worker;
        return worker.workName.toLowerCase() == widget.category.toLowerCase();
      }).toList();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _workerData = filteredWorkerData;
          _workers = filteredWorkerData
              .map((data) => data['worker'] as Worker)
              .toList();
          _favoritedWorkerIds = favoritedIds;
          _categoryList = _buildCategoryList();
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

  List<Widget> _buildCategoryList() {
    return _workerData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final worker = data['worker'] as Worker;
      final workerId = data['id'] as String;
      final isFavorited = _currentUser?.role == UserRole.regular &&
          _favoritedWorkerIds.contains(workerId);

      return Dismissible(
        key: ValueKey('${workerId}_$index'),
        direction: (_currentUser?.role == UserRole.admin ||
                _currentUser?.role == UserRole.regular)
            ? DismissDirection.startToEnd
            : DismissDirection.none,
        background: Container(
          color:
              _currentUser?.role == UserRole.admin ? Colors.red : Colors.yellow,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Icon(
            _currentUser?.role == UserRole.admin
                ? Icons.delete
                : Icons.favorite,
            color: Colors.white,
          ),
        ),
        confirmDismiss: (direction) async {
          if (_currentUser?.role == UserRole.admin) {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirm Delete'),
                  content:
                      Text('Are you sure you want to delete ${worker.name}?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          } else if (_currentUser?.role == UserRole.regular &&
              direction == DismissDirection.startToEnd) {
            if (!isFavorited) {
              await _addFavorite(worker, workerId);
              return false;
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('${worker.name} is already in favorites')),
                );
              }
              return false;
            }
          }
          return false;
        },
        onDismissed: (direction) {
          if (_currentUser?.role == UserRole.admin) {
            _deleteWorker(workerId, index);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkerDetailScreen(
                    worker: worker,
                    workerId: workerId,
                    isAdmin: _currentUser?.role == UserRole.admin,
                    firebaseService: widget.firebaseService,
                  ),
                ),
              ).then((_) => _loadUserAndData());
            },
            child: Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      'assets/funny1.jpg',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                worker.workName,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Off ${worker.discount}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFfd6b6d),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'By ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: worker.name,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFfef9e4),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Color(0xFFe8bc23),
                                        size: 15,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(worker.rate.toString()),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFf0edfb),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.attach_money_outlined,
                                        color: Color(0xFF1a253f),
                                        size: 15,
                                      ),
                                      Text('${worker.payment}/h'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _deleteWorker(String workerId, int index) async {
    try {
      setState(() {
        final workerToRemove = _workerData.firstWhere((data) => data['id'] as String == workerId);
        _workerData.remove(workerToRemove);
        _workers.removeWhere((worker) => _workerData.every((data) => data['worker'] != worker));
        _categoryList = _buildCategoryList();
      });
      
      await widget.firebaseService.deleteWorker(workerId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete worker: $e')),
        );
        _loadUserAndData();
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('${widget.category} Workers'),
      ),
      body: _workers.isEmpty
          ? Center(child: Text('No ${widget.category} workers found.'))
          : SingleChildScrollView(
              child: Column(
                children: _categoryList,
              ),
            ),
    );
  }
}
