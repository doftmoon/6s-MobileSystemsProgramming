import 'dart:io';

import 'package:flutter/material.dart';
import '../models/developer.dart';
import '../services/file_service.dart';
import '../db/database_helper.dart';

class FileOperationsScreen extends StatefulWidget {
  const FileOperationsScreen({super.key});

  @override
  _FileOperationsScreenState createState() => _FileOperationsScreenState();
}

class _FileOperationsScreenState extends State<FileOperationsScreen> {
  final FileService _fileService = FileService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Developer? _selectedDeveloper;
  final Map<String, Developer?> _loadedDevelopers = {
    'Temporary': null,
    'Application Support': null,
    'Application Library': null,
    'Application Documents': null,
    'Application Cache': null,
    'External Storage': null,
    'External Cache': null,
    'External Storage Directories': null,
    'Downloads': null,
  };

  List<Developer> _availableDevelopers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevelopers();
    _loadSavedFiles();
  }

  Future<void> _loadDevelopers() async {
    try {
      setState(() => _isLoading = true);
      _availableDevelopers = await _dbHelper.getAllDevelopers();
      if (_availableDevelopers.isNotEmpty) {
        _selectedDeveloper = _availableDevelopers.first;
      }
    } catch (e) {
      _showError('Ошибка загрузки разработчиков: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSavedFiles() async {
    try {
      setState(() => _isLoading = true);

      final results = await Future.wait([
        _fileService.readFromTemporary(),
        _fileService.readFromApplicationSupport(),
        if (Platform.isIOS) _fileService.readFromApplicationLibrary(),
        _fileService.readFromApplicationDocuments(),
        _fileService.readFromApplicationCache(),
      ]);

      setState(() {
        _loadedDevelopers['Temporary'] = results[0];
        _loadedDevelopers['Application Support'] = results[1];
        if (Platform.isIOS) {
          _loadedDevelopers['Application Library'] = results[2];
        }
        _loadedDevelopers['Application Documents'] = results[3];
        _loadedDevelopers['Application Cache'] = results[4];
      });

      // Загрузка для Android-специфичных директорий
      if (Platform.isAndroid) {
        try {
          final androidResults = await Future.wait([
            _fileService.readFromExternalStorage(),
            _fileService.readFromExternalCache(),
            _fileService.readFromExternalStorageDirectories(),
            _fileService.readFromDownloads(),
          ]);

          setState(() {
            _loadedDevelopers['External Storage'] = androidResults[0];
            _loadedDevelopers['External Cache'] = androidResults[1];
            _loadedDevelopers['External Storage Directories'] = androidResults[2];
            _loadedDevelopers['Downloads'] = androidResults[3];
          });
        } catch (e) {
          _showError('Ошибка загрузки Android-специфичных файлов: ${e.toString()}');
        }
      }
    } catch (e) {
      _showError('Ошибка загрузки файлов: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveToLocation(String location, Developer developer) async {
    try {
      // Проверяем, что разработчик выбран
      if (_selectedDeveloper == null) {
        throw Exception('Developer not selected');
      }

      // Сохраняем в соответствующую директорию
      switch (location) {
        case 'Temporary':
          await _fileService.saveToTemporary(developer);
          break;
        case 'Application Support':
          await _fileService.saveToApplicationSupport(developer);
          break;
        case 'Application Library':
          if (Platform.isIOS) {
            await _fileService.saveToApplicationLibrary(developer);
          } else {
            throw Exception('Application Library available only on iOS');
          }
          break;
        case 'Application Documents':
          await _fileService.saveToApplicationDocuments(developer);
          break;
        case 'Application Cache':
          await _fileService.saveToApplicationCache(developer);
          break;
        case 'External Storage':
          if (Platform.isAndroid) {
            await _fileService.saveToExternalStorage(developer);
          } else {
            throw Exception('External Storage available only on Android');
          }
          break;
        case 'External Cache':
          if (Platform.isAndroid) {
            await _fileService.saveToExternalCache(developer);
          } else {
            throw Exception('External Cache available only on Android');
          }
          break;
        case 'External Storage Directories':
          if (Platform.isAndroid) {
            await _fileService.saveToExternalStorageDirectories(developer);
          } else {
            throw Exception('External Storage Directories available only on Android');
          }
          break;
        case 'Downloads':
          if (Platform.isAndroid) {
            await _fileService.saveToDownloads(developer);
          } else {
            throw Exception('Downloads directory access limited on iOS');
          }
          break;
        default:
          throw Exception('Unknown location: $location');
      }

      _showSuccess('Successfully saved to $location');
      await _loadSavedFiles(); // Обновляем список загруженных файлов
    } catch (e) {
      _showError('Error saving to $location: ${e.toString()}');
      debugPrint('Save error details: $e');
    }
  }

  void _showError(String message) {

  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildLocationCard(String location, Developer? developer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            developer != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${developer.name}'),
                Text('Experience: ${developer.experienceYears} years'),
                Text('Salary: ${developer.salary}'),
                Text('Role: ${developer.role}'),
              ],
            )
                : const Text('No data saved'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _selectedDeveloper == null
                      ? null
                      : () => _saveToLocation(location, _selectedDeveloper!),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Operations')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _availableDevelopers.isEmpty
          ? const Center(
        child: Text('No developers available. Please add developers first.'),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select developer to save:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Developer>(
              value: _selectedDeveloper,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (Developer? newValue) {
                setState(() => _selectedDeveloper = newValue);
              },
              items: _availableDevelopers
                  .map<DropdownMenuItem<Developer>>(
                    (developer) => DropdownMenuItem<Developer>(
                  value: developer,
                  child: Text(developer.name),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select storage location:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._loadedDevelopers.entries.map(
                  (entry) => _buildLocationCard(entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }
}