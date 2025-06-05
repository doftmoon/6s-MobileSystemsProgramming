import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/favorite_item.dart';
import '../models/user.dart';
import '../models/worker.dart';
import 'worker_detail_screen.dart';
import 'package:lab11_13_deez_nuts/services/firebase_service.dart';

class FavoritesListWidget extends StatefulWidget {
  final FirebaseService firebaseService;

  const FavoritesListWidget({super.key, required this.firebaseService});

  @override
  State<FavoritesListWidget> createState() => _FavoritesListWidgetState();
}

class _FavoritesListWidgetState extends State<FavoritesListWidget> {
  List<FavoriteItem> _favorites = [];
  List<Map<String, dynamic>> _workerData = [];
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserAndFavorites();
  }

  Future<void> _loadUserAndFavorites() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to view favorites')),
          );
        }
        return;
      }

      final user = await widget.firebaseService.getUser(userId);
      final favorites = await widget.firebaseService.getFavorites(userId);
      final workers = await widget.firebaseService.getWorkers();
      final favoriteWorkerData =
          workers.where((worker) {
            return favorites.any((fav) => fav.itemId == worker['id']);
          }).toList();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _favorites = favorites;
          _workerData = favoriteWorkerData;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load favorites: $e')));
      }
    }
  }

  Future<void> _removeFavorite(String itemId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await widget.firebaseService.deleteFavorite(userId, itemId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
        _loadUserAndFavorites();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove favorite: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body:
          _workerData.isEmpty
              ? const Center(child: Text('No favorites added yet.'))
              : ListView.builder(
                itemCount: _workerData.length,
                itemBuilder: (context, index) {
                  final worker = _workerData[index]['worker'] as Worker;
                  final workerId = _workerData[index]['id'] as String;

                  return Dismissible(
                    key: Key(worker.name),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Remove'),
                            content: Text(
                              'Remove ${worker.name} from favorites?',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: const Text('Remove'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      _removeFavorite(workerId);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 10,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => WorkerDetailScreen(
                                    worker: worker,
                                    workerId: workerId,
                                    isAdmin:
                                        _currentUser?.role == UserRole.admin,
                                    firebaseService: widget.firebaseService,
                                  ),
                            ),
                          ).then((_) => _loadUserAndFavorites());
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            worker.workName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
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
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 20,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFfef9e4),
                                              borderRadius:
                                                  BorderRadius.circular(2),
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
                                            margin: const EdgeInsets.only(
                                              top: 20,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFf0edfb),
                                              borderRadius:
                                                  BorderRadius.circular(2),
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
                },
              ),
    );
  }
}
