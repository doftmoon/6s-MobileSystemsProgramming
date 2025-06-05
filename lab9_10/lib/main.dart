import 'package:flutter/material.dart';
import 'package:lab4_5_widgets/routes.dart';
import 'package:provider/provider.dart';

import 'global_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GlobalAppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomeChores',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      initialRoute: '/',
      routes: routes,
    );
  }
}
