import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/worker.dart';
import '../services/firebase_service.dart';
import '../services/connectivity_service.dart';

class WorkerDetailScreen extends StatefulWidget {
  final Worker worker;
  final String workerId;
  final bool isAdmin;
  final FirebaseService firebaseService;

  const WorkerDetailScreen({
    super.key,
    required this.worker,
    required this.workerId,
    required this.isAdmin,
    required this.firebaseService,
  });

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _workNameController;
  late TextEditingController _nameController;
  late TextEditingController _rateController;
  late TextEditingController _discountController;
  late TextEditingController _paymentController;
  UserModel? _currentUser;
  bool _isOfflineMode = false;
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _workNameController = TextEditingController(text: widget.worker.workName);
    _nameController = TextEditingController(text: widget.worker.name);
    _rateController =
        TextEditingController(text: widget.worker.rate.toString());
    _discountController =
        TextEditingController(text: widget.worker.discount.toString());
    _paymentController =
        TextEditingController(text: widget.worker.payment.toString());
    _loadUser();
    _checkConnectivity();
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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final user = await widget.firebaseService.getUser(userId);
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _workNameController.dispose();
    _nameController.dispose();
    _rateController.dispose();
    _discountController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  Future<void> _updateWorker() async {
    if (_isOfflineMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot update while offline')),
      );
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      try {
        final updatedWorker = Worker(
          workName: _workNameController.text,
          name: _nameController.text,
          rate: double.parse(_rateController.text),
          discount: double.parse(_discountController.text),
          payment: double.parse(_paymentController.text),
        );

        await widget.firebaseService
            .updateWorker(widget.workerId, updatedWorker);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Worker updated successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update worker: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canEdit = widget.isAdmin && !_isOfflineMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Details'),
        actions: [
          if (_isOfflineMode)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'OFFLINE',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const Text('Work Name:'),
              const SizedBox(height: 4),
              canEdit
                  ? TextFormField(
                      controller: _workNameController,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter work name';
                        }
                        return null;
                      },
                    )
                  : Text(
                      widget.worker.workName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
              const SizedBox(height: 16),
              const Text('Name:'),
              const SizedBox(height: 4),
              canEdit
                  ? TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    )
                  : Text(
                      widget.worker.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
              const SizedBox(height: 16),
              const Text('Rate:'),
              const SizedBox(height: 4),
              canEdit
                  ? TextFormField(
                      controller: _rateController,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter rate';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    )
                  : Text(
                      widget.worker.rate.toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
              const SizedBox(height: 16),
              const Text('Discount (%):'),
              const SizedBox(height: 4),
              canEdit
                  ? TextFormField(
                      controller: _discountController,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter discount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    )
                  : Text(
                      widget.worker.discount.toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
              const SizedBox(height: 16),
              const Text('Payment:'),
              const SizedBox(height: 4),
              canEdit
                  ? TextFormField(
                      controller: _paymentController,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter payment';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    )
                  : Text(
                      widget.worker.payment.toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
              const SizedBox(height: 32),
              if (canEdit)
                ElevatedButton(
                  onPressed: _updateWorker,
                  child: const Text('Update Worker'),
                ),
              if (_isOfflineMode)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Editing is disabled in offline mode',
                    style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
