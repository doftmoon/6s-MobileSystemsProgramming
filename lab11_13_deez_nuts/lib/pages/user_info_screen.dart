import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';

class UserInfoScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const UserInfoScreen({super.key, required this.firebaseService});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  User? _currentUser;
  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      if (_currentUser != null) {
        _userModel = await widget.firebaseService.getUser(_currentUser!.uid);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user info: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/signIn');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('No user signed in'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${_currentUser!.email ?? 'Not available'}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text('Display Name: ${_userModel?.name ?? 'Not set'}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text('User ID: ${_currentUser!.uid}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text(
                          'Role: ${_userModel?.role.toString().split('.').last ?? 'Not set'}',
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
    );
  }
}
