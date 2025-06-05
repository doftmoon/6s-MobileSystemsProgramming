import 'package:flutter/material.dart';
import 'package:lab11_13_deez_nuts/models/worker.dart';
import 'package:lab11_13_deez_nuts/services/firebase_service.dart';

class CreateWorkerDialog extends StatefulWidget {
  final FirebaseService firebaseService;

  const CreateWorkerDialog({super.key, required this.firebaseService});

  @override
  State<CreateWorkerDialog> createState() => _CreateWorkerDialogState();
}

class _CreateWorkerDialogState extends State<CreateWorkerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _workNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _rateController = TextEditingController();
  final _discountController = TextEditingController();
  final _paymentController = TextEditingController();

  @override
  void dispose() {
    _workNameController.dispose();
    _nameController.dispose();
    _rateController.dispose();
    _discountController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  Future<void> _saveWorker() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newWorker = Worker(
          workName: _workNameController.text,
          name: _nameController.text,
          rate: double.parse(_rateController.text),
          discount: double.parse(_discountController.text),
          payment: double.parse(_paymentController.text),
        );

        await widget.firebaseService.createWorker(newWorker);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Worker ${newWorker.name} created successfully'),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create worker: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Worker'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _workNameController,
                decoration: const InputDecoration(labelText: 'Work Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter work name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(labelText: 'Rate'),
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
              ),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'Discount (%)'),
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
              ),
              TextFormField(
                controller: _paymentController,
                decoration: const InputDecoration(
                  labelText: 'Payment per Hour',
                ),
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
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        ElevatedButton(onPressed: _saveWorker, child: const Text('Save')),
      ],
    );
  }
}
