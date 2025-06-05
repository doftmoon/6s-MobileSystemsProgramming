import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';
import '../services/connectivity_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const SignInScreen({super.key, required this.firebaseService});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _isOffline = false;
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    
    // Listen for connectivity changes
    _connectivityService.connectionStatus.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isOffline = !isConnected;
        });
      }
    });
  }
  
  Future<void> _checkConnectivity() async {
    final isConnected = await _connectivityService.isConnected();
    if (mounted) {
      setState(() {
        _isOffline = !isConnected;
      });
    }
  }

  Future<void> _signInWithEmail() async {
    if (_isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot sign in while offline')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    try {
      if (_isSignUp) {
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(
                UserModel(
                  id: user.uid,
                  name: _nameController.text.trim(),
                  role: UserRole.regular,
                ).toJson(),
              );
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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

  Future<void> _signInWithGoogle() async {
    if (_isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot sign in with Google while offline')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    try {
      final userCredential = await widget.firebaseService.signInWithGoogle();
      if (userCredential == null) {
        throw Exception('Google sign-in failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Error: $e')),
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

  Future<void> _resetPassword() async {
    if (_isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot reset password while offline')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    try {
      if (_emailController.text.trim().isEmpty) {
        throw Exception('Please enter your email address');
      }
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent to your email!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          key: const ValueKey("SignIn"),
          children: [
            if (_isOffline)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.red),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.signal_wifi_off, color: Colors.red),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'You are offline. Please connect to the internet to sign in.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            if (_isSignUp)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                enabled: !_isOffline,
                key: const ValueKey("SignUp"),
              ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isOffline,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              enabled: !_isOffline,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _isOffline ? null : _signInWithEmail,
                    child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                  ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp;
                });
              },
              child: Text(_isSignUp
                  ? 'Already have an account? Sign In'
                  : 'Need an account? Sign Up'),
            ),
            if (!_isSignUp)
              TextButton(
                onPressed: _isOffline ? null : _resetPassword,
                child: const Text('Forgot Password?'),
              ),
            const Divider(),
            ElevatedButton.icon(
              onPressed: _isOffline ? null : _signInWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
            ),
            if (_isOffline)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton.icon(
                  onPressed: _checkConnectivity,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Connection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
