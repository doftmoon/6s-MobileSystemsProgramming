import 'package:flutter/material.dart';
import '../models/developer.dart';
import '../db/database_helper.dart';
import 'developer_detail_screen.dart';
import 'developer_form_screen.dart';
import 'file_operations_screen.dart';

class DeveloperListScreen extends StatefulWidget {
  const DeveloperListScreen({super.key});

  @override
  _DeveloperListScreenState createState() => _DeveloperListScreenState();
}

class _DeveloperListScreenState extends State<DeveloperListScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Developer> developers = [];
  bool isLoading = true;
  String sortColumnName = 'name';
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    refreshDevelopersList();
  }

  Future<void> refreshDevelopersList() async {
    setState(() {
      isLoading = true;
    });

    try {
      developers = await dbHelper.getDevelopersSortedBy(
        sortColumnName,
        sortAscending,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка загрузки данных: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _changeSorting(String column) {
    setState(() {
      if (sortColumnName == column) {
        // Если та же колонка, меняем направление сортировки
        sortAscending = !sortAscending;
      } else {
        // Если новая колонка, устанавливаем сортировку по возрастанию
        sortColumnName = column;
        sortAscending = true;
      }
    });
    refreshDevelopersList();
  }

  Future<void> _deleteDeveloper(int id) async {
    try {
      await dbHelper.delete(id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Разработчик удален')));
      refreshDevelopersList();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список разработчиков'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortingOptions(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FileOperationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : developers.isEmpty
              ? const Center(child: Text('Нет данных. Добавьте разработчиков'))
              : ListView.builder(
                itemCount: developers.length,
                itemBuilder: (context, index) {
                  final developer = developers[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(developer.name),
                      subtitle: Text(
                        'Опыт: ${developer.experienceYears} лет | Зарплата: ${developer.salary} руб | Роль: ${developer.role}',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    DeveloperDetailScreen(developer: developer),
                          ),
                        ).then((_) => refreshDevelopersList());
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DeveloperFormScreen(
                                        developer: developer,
                                      ),
                                ),
                              ).then((_) => refreshDevelopersList());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed:
                                () => _showDeleteConfirmationDialog(developer),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeveloperFormScreen(),
            ),
          ).then((_) => refreshDevelopersList());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSortingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('По имени'),
                trailing:
                    sortColumnName == 'name'
                        ? Icon(
                          sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        )
                        : null,
                onTap: () {
                  Navigator.pop(context);
                  _changeSorting('name');
                },
              ),
              ListTile(
                leading: const Icon(Icons.work_history),
                title: const Text('По опыту'),
                trailing:
                    sortColumnName == 'experienceYears'
                        ? Icon(
                          sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        )
                        : null,
                onTap: () {
                  Navigator.pop(context);
                  _changeSorting('experienceYears');
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('По зарплате'),
                trailing:
                    sortColumnName == 'salary'
                        ? Icon(
                          sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        )
                        : null,
                onTap: () {
                  Navigator.pop(context);
                  _changeSorting('salary');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('По роли'),
                trailing:
                    sortColumnName == 'role'
                        ? Icon(
                          sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        )
                        : null,
                onTap: () {
                  Navigator.pop(context);
                  _changeSorting('role');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Developer developer) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Подтверждение удаления'),
            content: Text(
              'Вы уверены, что хотите удалить "${developer.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteDeveloper(developer.id!);
                },
                child: const Text('Удалить'),
              ),
            ],
          ),
    );
  }
}
