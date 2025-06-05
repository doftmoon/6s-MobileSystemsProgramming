import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/developer.dart';
import '../db/database_helper.dart';

class DeveloperFormScreen extends StatefulWidget {
  final Developer? developer;

  const DeveloperFormScreen({super.key, this.developer});

  @override
  _DeveloperFormScreenState createState() => _DeveloperFormScreenState();
}

class _DeveloperFormScreenState extends State<DeveloperFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final _salaryController = TextEditingController();
  final _roleController = TextEditingController();

  final dbHelper = DatabaseHelper.instance;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    isEditing = widget.developer != null;
    if (isEditing) {
      _nameController.text = widget.developer!.name;
      _experienceYearsController.text =
          widget.developer!.experienceYears.toString();
      _salaryController.text = widget.developer!.salary.toString();
      _roleController.text = widget.developer!.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _experienceYearsController.dispose();
    _salaryController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _saveDeveloper() async {
    if (_formKey.currentState!.validate()) {
      try {
        final name = _nameController.text;
        final experienceYears = int.parse(_experienceYearsController.text);
        final salary = double.parse(_salaryController.text);
        final role = _roleController.text;

        Developer developer;
        int result;

        if (isEditing) {
          developer = widget.developer!.copyWith(
            name: name,
            experienceYears: experienceYears,
            salary: salary,
            role: role,
          );
          result = await dbHelper.update(developer);
        } else {
          developer = Developer(
            name: name,
            experienceYears: experienceYears,
            salary: salary,
            role: role,
          );
          result = await dbHelper.insert(developer);
        }

        if (result > 0) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Разработчик обновлен успешно'
                    : 'Разработчик добавлен успешно',
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          throw Exception('Не удалось сохранить разработчика');
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Редактировать разработчика' : 'Добавить разработчика',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите имя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _experienceYearsController,
                decoration: const InputDecoration(
                  labelText: 'Опыт (лет)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите количество лет опыта';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Опыт должен быть числом';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Зарплата (руб)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите зарплату';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Зарплата должна быть числом';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Роль',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите роль';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _saveDeveloper,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: Text(
                  isEditing ? 'Обновить' : 'Добавить',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
