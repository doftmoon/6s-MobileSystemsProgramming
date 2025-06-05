import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/worker.dart';
import '../models/user.dart';
import 'category.dart';
import 'worker_detail_screen.dart';
import '../services/firebase_service.dart';

class Home extends StatefulWidget {
  final PageController pageController;
  final FirebaseService firebaseService;

  const Home(
      {super.key, required this.pageController, required this.firebaseService});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SearchController _searchController = SearchController();
  List<Map<String, dynamic>> _workerData = [];
  List<Widget> _cardList = [];
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final user = await widget.firebaseService.getUser(userId);
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<void> _loadWorkers() async {
    try {
      final workerData = await widget.firebaseService.getWorkers();
      if (mounted) {
        setState(() {
          _workerData = workerData;
          _cardList = _buildCardList(workerData);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load workers: $e')),
        );
      }
    }
  }

  List<Widget> _buildCardList(List<Map<String, dynamic>> workerData) {
    return workerData.map((data) {
      final worker = data['worker'] as Worker;
      final workerId = data['id'] as String;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          children: [
            GestureDetector(
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
                ).then((_) => _loadWorkers());
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
                                        style: const TextStyle(
                                            color: Colors.black),
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
          ],
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        key: const ValueKey("HomeScreen"),
        child: Column(
          children: [
            SearchAnchor(
              searchController: _searchController,
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  leading: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  elevation: WidgetStateProperty.all(1),
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16)),
                  hintText: 'Search workers',
                  hintStyle: WidgetStateProperty.all<TextStyle>(
                    TextStyle(color: Colors.grey.shade400),
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                final query = controller.text.toLowerCase();
                final suggestions = _workerData.where((data) {
                  final worker = data['worker'] as Worker;
                  return worker.workName.toLowerCase().contains(query) ||
                      worker.name.toLowerCase().contains(query);
                }).toList();
                return suggestions.map((data) {
                  final worker = data['worker'] as Worker;
                  return ListTile(
                    title: Text(worker.workName),
                    subtitle: Text(worker.name),
                    onTap: () {
                      controller.closeView(worker.workName);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkerDetailScreen(
                            worker: worker,
                            workerId: data['id'] as String,
                            isAdmin: _currentUser?.role == UserRole.admin,
                            firebaseService: widget.firebaseService,
                          ),
                        ),
                      );
                    },
                  );
                }).toList();
              },
            ),
            Container(
              height: 150,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFfd6b6d),
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 140,
                    child: Container(
                      width: 250,
                      height: 250,
                      transform: Matrix4.identity()
                        ..rotateX(50 * pi / 180)
                        ..rotateY(-15 * pi / 180)
                        ..rotateZ(10 * pi / 180),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFfd6b6d),
                            const Color(0xFFfd6b6d),
                            const Color(0xFFfd6b6d),
                            const Color(0xFFfd6b6d),
                            const Color(0xFFff7279),
                            const Color(0xFFf88d8c),
                            const Color(0xFFf89f9f),
                            const Color(0xFFffa9a3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 120,
                    child: Container(
                      width: 210,
                      height: 200,
                      transform: Matrix4.identity()
                        ..rotateX(50 * pi / 180)
                        ..rotateY(-15 * pi / 180)
                        ..rotateZ(0 * pi / 180),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFfd6b6d),
                            const Color(0xFFfd6b6d),
                            const Color(0xFFfd6b6d),
                            const Color(0xFFfd6b6d),
                            const Color(0xFFff7279),
                            const Color(0xFFf88d8c),
                            const Color(0xFFf89f9f),
                            const Color(0xFFffa9a3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 110,
                    child: Container(
                      width: 200,
                      height: 130,
                      transform: Matrix4.identity()
                        ..rotateX(50 * pi / 180)
                        ..rotateY(-15 * pi / 180)
                        ..rotateZ(0 * pi / 180),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFfd6b6d),
                            const Color(0xFFfd6b6d),
                            const Color(0xFFfd6b6d),
                            const Color(0xFFfd6b6d),
                            const Color(0xFFff7279),
                            const Color(0xFFf88d8c),
                            const Color(0xFFf89f9f),
                            const Color(0xFFffa9a3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    top: 15,
                    child: SizedBox(
                      width: 210,
                      child: Text(
                        'What services do you need?',
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          height: 1.1,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 15,
                    top: 90,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.pageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Get started',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Color(0xFFfd6b6d),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Category', style: TextStyle(fontSize: 20)),
                      TextButton(
                        onPressed: () {
                          widget.pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFfd6b6d),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetails(
                                category: 'Cleaning',
                                firebaseService: widget.firebaseService,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: const Color(0x3394c3a6),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.cleaning_services_outlined,
                                  color: const Color(0xFF4e6957),
                                  size: 35,
                                ),
                              ),
                            ),
                            const Text(
                              'Cleaning',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4e6957),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetails(
                                category: 'Repair',
                                firebaseService: widget.firebaseService,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: const Color(0x228faec1),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.home_repair_service_outlined,
                                  color: const Color(0xFF8faec1),
                                  size: 35,
                                ),
                              ),
                            ),
                            const Text(
                              'Repair',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8faec1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetails(
                                category: 'Laundry',
                                firebaseService: widget.firebaseService,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: const Color(0x22ddab8e),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.local_laundry_service_outlined,
                                  color: const Color(0xFFddab8e),
                                  size: 35,
                                ),
                              ),
                            ),
                            const Text(
                              'Laundry',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFddab8e),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetails(
                                category: 'Painting',
                                firebaseService: widget.firebaseService,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: const Color(0x22857ccc),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.format_paint_outlined,
                                  color: const Color(0xFF857ccc),
                                  size: 35,
                                ),
                              ),
                            ),
                            const Text(
                              'Painting',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF857ccc),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recommended', style: TextStyle(fontSize: 20)),
                      TextButton(
                        onPressed: () {
                          widget.pageController.animateToPage(
                            1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFfd6b6d),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: _cardList,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
