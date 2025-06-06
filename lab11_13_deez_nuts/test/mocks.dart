import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab11_13_deez_nuts/services/connectivity_service.dart';
import 'package:lab11_13_deez_nuts/services/firebase_service.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

@GenerateMocks([
  Connectivity,
  ConnectivityService,
  Database,
  DatabaseExecutor,
  FirebaseService,
  FirebaseAuth,
  User,
])
void main() {}
