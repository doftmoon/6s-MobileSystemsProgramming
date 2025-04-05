import 'package:flutter/material.dart';

class CleaningPage extends StatelessWidget {
  const CleaningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Cleaning Page'),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
