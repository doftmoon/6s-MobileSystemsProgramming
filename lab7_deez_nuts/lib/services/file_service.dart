import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/developer.dart';

class FileService {
  Future<Map<String, String>> getAllDirectoryPaths() async {
    final paths = <String, String>{};

    try {
      paths['Temporary'] = (await getTemporaryDirectory()).path;
    } catch (e) {
      paths['Temporary'] = 'Недоступно: $e';
    }

    try {
      paths['Application Support'] = (await getApplicationSupportDirectory()).path;
    } catch (e) {
      paths['Application Support'] = 'Недоступно: $e';
    }

    try {
      paths['Application Library'] = (await getLibraryDirectory()).path;
    } catch (e) {
      paths['Application Library'] = 'Недоступно: $e';
    }

    try {
      paths['Application Documents'] = (await getApplicationDocumentsDirectory()).path;
    } catch (e) {
      paths['Application Documents'] = 'Недоступно: $e';
    }

    try {
      paths['Application Cache'] = (await getApplicationCacheDirectory()).path;
    } catch (e) {
      paths['Application Cache'] = 'Недоступно: $e';
    }

    try {
      if (Platform.isAndroid) {
        final dir = await getExternalStorageDirectory();
        paths['External Storage'] = dir?.path ?? 'Недоступно';
      } else {
        paths['External Storage'] = 'Только для Android';
      }
    } catch (e) {
      paths['External Storage'] = 'Недоступно: $e';
    }

    try {
      if (Platform.isAndroid) {
        final dirs = await getExternalCacheDirectories();
        paths['External Cache Directories'] = dirs?.map((e) => e.path).join(', ') ?? 'Пустой';
      } else {
        paths['External Cache Directories'] = 'Только для Android';
      }
    } catch (e) {
      paths['External Cache Directories'] = 'Недоступно: $e';
    }

    try {
      if (Platform.isAndroid) {
        final dirs = await getExternalStorageDirectories();
        paths['External Storage Directories'] = dirs?.map((e) => e.path).join(', ') ?? 'Пустой';
      } else {
        paths['External Storage Directories'] = 'Только для Android';
      }
    } catch (e) {
      paths['External Storage Directories'] = 'Недоступно: $e';
    }

    try {
      final dir = await getDownloadsDirectory();
      paths['Downloads'] = dir?.path ?? 'Недоступно';
    } catch (e) {
      paths['Downloads'] = 'Недоступно: $e';
    }

    return paths;
  }

  // Реализации для всех методов записи/чтения

  // Temporary - доступно на обеих платформах
  Future<void> saveToTemporary(Developer developer) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/developer_temp.json');
      await file.writeAsString(json.encode(developer.toMap()));
    } catch (e) {
      throw Exception('Ошибка записи во временную директорию: $e');
    }
  }

  Future<Developer?> readFromTemporary() async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/developer_temp.json');
      return await _readDeveloperFile(file);
    } catch (e) {
      throw Exception('Ошибка чтения из временной директории: $e');
    }
  }

  // Application Support - доступно на обеих платформах
  Future<void> saveToApplicationSupport(Developer developer) async {
    try {
      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/developer_support.json');
      await file.writeAsString(json.encode(developer.toMap()));
    } catch (e) {
      throw Exception('Ошибка записи в директорию поддержки приложения: $e');
    }
  }

  Future<Developer?> readFromApplicationSupport() async {
    try {
      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/developer_support.json');
      return await _readDeveloperFile(file);
    } catch (e) {
      throw Exception('Ошибка чтения из директории поддержки приложения: $e');
    }
  }

  // Application Documents - доступно на обеих платформах
  Future<void> saveToApplicationDocuments(Developer developer) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/developer_docs.json');
      await file.writeAsString(json.encode(developer.toMap()));
    } catch (e) {
      throw Exception('Ошибка записи в директорию документов приложения: $e');
    }
  }

  Future<Developer?> readFromApplicationDocuments() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/developer_docs.json');
      return await _readDeveloperFile(file);
    } catch (e) {
      throw Exception('Ошибка чтения из директории документов приложения: $e');
    }
  }

  // Application Cache - доступно на обеих платформах
  Future<void> saveToApplicationCache(Developer developer) async {
    try {
      final directory = await getApplicationCacheDirectory();
      final file = File('${directory.path}/developer_cache.json');
      await file.writeAsString(json.encode(developer.toMap()));
    } catch (e) {
      throw Exception('Ошибка записи в кэш приложения: $e');
    }
  }

  Future<Developer?> readFromApplicationCache() async {
    try {
      final directory = await getApplicationCacheDirectory();
      final file = File('${directory.path}/developer_cache.json');
      return await _readDeveloperFile(file);
    } catch (e) {
      throw Exception('Ошибка чтения из кэша приложения: $e');
    }
  }

  // Application Library - только для iOS
  Future<void> saveToApplicationLibrary(Developer developer) async {
    try {
      if (!Platform.isIOS) throw Exception('Только для iOS');

      final directory = await getLibraryDirectory();
      final file = File('${directory.path}/developer_library.json');
      await file.writeAsString(json.encode(developer.toMap()));
    } catch (e) {
      throw Exception('Ошибка записи в библиотеку: $e');
    }
  }

  Future<Developer?> readFromApplicationLibrary() async {
    try {
      if (!Platform.isIOS) throw Exception('Только для iOS');

      final directory = await getLibraryDirectory();
      final file = File('${directory.path}/developer_library.json');
      return await _readDeveloperFile(file);
    } catch (e) {
      throw Exception('Ошибка чтения из библиотеки: $e');
    }
  }

  // External Storage - только для Android
  Future<void> saveToExternalStorage(Developer developer) async {
    try {
      if (!Platform.isAndroid) throw Exception('Только для Android');

      final directory = await getExternalStorageDirectory();
      if (directory == null) throw Exception('Внешнее хранилище недоступно');

      final file = File('${directory.path}/developer_external.json');
      await file.writeAsString(json.encode(developer.toMap()));
    } catch (e) {
      throw Exception('Ошибка записи во внешнее хранилище: $e');
    }
  }

  Future<Developer?> readFromExternalStorage() async {
    try {
      if (!Platform.isAndroid) throw Exception('Только для Android');

      final directory = await getExternalStorageDirectory();
      if (directory == null) return null;

      final file = File('${directory.path}/developer_external.json');
      return await _readDeveloperFile(file);
    } catch (e) {
      throw Exception('Ошибка чтения из внешнего хранилища: $e');
    }
  }

  // External Cache Directories - только для Android
  Future<void> saveToExternalCache(Developer developer) async {
    try {
      if (!Platform.isAndroid) throw Exception('Только для Android');

      final directories = await getExternalCacheDirectories();
      if (directories == null || directories.isEmpty) {
        throw Exception('Директории не найдены');
      }

      final file = File('${directories.first.path}/developer_external_cache.json');
      await file.writeAsString(json.encode(developer.toMap()));
    } catch (e) {
      throw Exception('Ошибка записи во внешний кэш: $e');
    }
  }

  Future<Developer?> readFromExternalCache() async {
    try {
      if (!Platform.isAndroid) throw Exception('Только для Android');

      final directories = await getExternalCacheDirectories();
      if (directories == null || directories.isEmpty) return null;

      final file = File('${directories.first.path}/developer_external_cache.json');
      return await _readDeveloperFile(file);
    } catch (e) {
      throw Exception('Ошибка чтения из внешнего кэша: $e');
    }
  }

  // External Storage Directories - только для Android
  Future<void> saveToExternalStorageDirectories(Developer developer) async {
    try {
      if (!Platform.isAndroid) throw Exception('Только для Android');

      final directories = await getExternalStorageDirectories();
      if (directories == null || directories.isEmpty) {
        throw Exception('Директории не найдены');
      }

      final file = File('${directories.first.path}/developer_external_storage.json');
      await file.writeAsString(json.encode(developer.toMap()));
    } catch (e) {
      throw Exception('Ошибка записи во внешние хранилища: $e');
    }
  }

  Future<Developer?> readFromExternalStorageDirectories() async {
    try {
      if (!Platform.isAndroid) throw Exception('Только для Android');

      final directories = await getExternalStorageDirectories();
      if (directories == null || directories.isEmpty) return null;

      final file = File('${directories.first.path}/developer_external_storage.json');
      return await _readDeveloperFile(file);
    } catch (e) {
      throw Exception('Ошибка чтения из внешних хранилищ: $e');
    }
  }

  // Downloads - с проверкой доступности на платформе
  Future<void> saveToDownloads(Developer developer) async {
    try {
      if (Platform.isIOS) throw Exception('На iOS доступ ограничен');

      final directory = await getDownloadsDirectory();
      if (directory == null) throw Exception('Директория загрузок недоступна');

      final file = File('${directory.path}/developer_downloads.json');
      await file.writeAsString(json.encode(developer.toMap()));
    } catch (e) {
      throw Exception('Ошибка записи в директорию загрузок: $e');
    }
  }

  Future<Developer?> readFromDownloads() async {
    try {
      if (Platform.isIOS) throw Exception('На iOS доступ ограничен');

      final directory = await getDownloadsDirectory();
      if (directory == null) return null;

      final file = File('${directory.path}/developer_downloads.json');
      return await _readDeveloperFile(file);
    } catch (e) {
      throw Exception('Ошибка чтения из директории загрузок: $e');
    }
  }

  // Общая вспомогательная функция для чтения
  Future<Developer?> _readDeveloperFile(File file) async {
    if (!await file.exists()) return null;
    final jsonString = await file.readAsString();
    return Developer.fromMap(json.decode(jsonString));
  }
}