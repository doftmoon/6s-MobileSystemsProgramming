import 'dart:async';
import 'dart:convert';

mixin SkillMixin {
  List<String> skills = [];

  void learnSkill(String skill) {
    skills.add(skill);
    print('Learned skill: $skill');
  }

  void showSkills() {
    print('Skills: ${skills.join(', ')}');
  }
}

abstract class IDeveloper {
  String getRole();
}

abstract class DeveloperRole {
  void writeCode();
  void solveProblems();
}

class Developer extends DeveloperRole with SkillMixin implements Comparable<Developer>, Iterator<String>, Iterable<String>{
  String name;
  int _experience;
  List<String> skills;
  int _index = -1;
  static int totalDevs = 0;

  Developer(this.name, this._experience, this.skills) {
    totalDevs++;
  }

  Developer.junior(this.name) :
        _experience = 0,
        skills = ['Basic Programming'];

  int get experience => _experience;

  set experience(int years) {
    if (years >= 0) {
      _experience = years;
    }
  }

//Functions
  static void printDevCount() {
    print('Total devs: $totalDevs');
  }

  void updateExperience([int years = 1]) {
    _experience += years;
  }

  void executeTask(Function task) {
    task();
  }

  void addSkills([List<String>? newSkills]) {
    if (newSkills != null) {
      skills.addAll(newSkills);
    }
  }

  @override
  void writeCode() {
    print('$name is writing code');
  }

  @override
  void solveProblems() {
    print('$name is solving problems');
  }

  @override
  int compareTo(Developer other) {
    return _experience.compareTo(other.experience);
  }

  @override
  bool moveNext() {
    _index++;
    return _index < skills.length;
  }

  @override
  Iterator<String> get iterator => skills.iterator;

  String toJson() {
    return jsonEncode({
      'name': name,
      'experience': _experience,
      'skills': skills,
    });
  }

  int calcSalary() {
    // TODO: implement calcSalary
    throw UnimplementedError();
  }

  @override
  bool any(bool Function(String element) test) {
    // TODO: implement any
    throw UnimplementedError();
  }

  @override
  Iterable<R> cast<R>() {
    // TODO: implement cast
    throw UnimplementedError();
  }

  @override
  bool contains(Object? element) {
    // TODO: implement contains
    throw UnimplementedError();
  }

  @override
  String elementAt(int index) {
    // TODO: implement elementAt
    throw UnimplementedError();
  }

  @override
  bool every(bool Function(String element) test) {
    // TODO: implement every
    throw UnimplementedError();
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(String element) toElements) {
    // TODO: implement expand
    throw UnimplementedError();
  }

  @override
  // TODO: implement first
  String get first => throw UnimplementedError();

  @override
  String firstWhere(bool Function(String element) test, {String Function()? orElse}) {
    // TODO: implement firstWhere
    throw UnimplementedError();
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, String element) combine) {
    // TODO: implement fold
    throw UnimplementedError();
  }

  @override
  Iterable<String> followedBy(Iterable<String> other) {
    // TODO: implement followedBy
    throw UnimplementedError();
  }

  @override
  void forEach(void Function(String element) action) {
    // TODO: implement forEach
  }

  @override
  // TODO: implement isEmpty
  bool get isEmpty => throw UnimplementedError();

  @override
  // TODO: implement isNotEmpty
  bool get isNotEmpty => throw UnimplementedError();

  @override
  String join([String separator = ""]) {
    // TODO: implement join
    throw UnimplementedError();
  }

  @override
  // TODO: implement last
  String get last => throw UnimplementedError();

  @override
  String lastWhere(bool Function(String element) test, {String Function()? orElse}) {
    // TODO: implement lastWhere
    throw UnimplementedError();
  }

  @override
  // TODO: implement length
  int get length => throw UnimplementedError();

  @override
  Iterable<T> map<T>(T Function(String e) toElement) {
    // TODO: implement map
    throw UnimplementedError();
  }

  @override
  String reduce(String Function(String value, String element) combine) {
    // TODO: implement reduce
    throw UnimplementedError();
  }

  @override
  // TODO: implement single
  String get single => throw UnimplementedError();

  @override
  String singleWhere(bool Function(String element) test, {String Function()? orElse}) {
    // TODO: implement singleWhere
    throw UnimplementedError();
  }

  @override
  Iterable<String> skip(int count) {
    // TODO: implement skip
    throw UnimplementedError();
  }

  @override
  Iterable<String> skipWhile(bool Function(String value) test) {
    // TODO: implement skipWhile
    throw UnimplementedError();
  }

  @override
  Iterable<String> take(int count) {
    // TODO: implement take
    throw UnimplementedError();
  }

  @override
  Iterable<String> takeWhile(bool Function(String value) test) {
    // TODO: implement takeWhile
    throw UnimplementedError();
  }

  @override
  List<String> toList({bool growable = true}) {
    // TODO: implement toList
    throw UnimplementedError();
  }

  @override
  Set<String> toSet() {
    // TODO: implement toSet
    throw UnimplementedError();
  }

  @override
  Iterable<String> where(bool Function(String element) test) {
    // TODO: implement where
    throw UnimplementedError();
  }

  @override
  Iterable<T> whereType<T>() {
    // TODO: implement whereType
    throw UnimplementedError();
  }

  @override
  // TODO: implement current
  String get current => throw UnimplementedError();
}

class FrontendDeveloper extends Developer implements IDeveloper {
  String framework;

  FrontendDeveloper(String name, int experienceYears, List<String> skills, this.framework)
      : super(name, experienceYears, skills);

  @override
  String getRole() => 'Frontend Developer';

  @override
  int calcSalary() => _experience * 20000;
}

class BackendDeveloper extends Developer implements IDeveloper {
  String database;

  BackendDeveloper(String name, int experienceYears, List<String> skills, this.database)
      : super(name, experienceYears, skills);

  @override
  String getRole() => 'Backend Developer';

  @override
  int calcSalary() => _experience * 25000;
}

void main() async {
  var dev1 = FrontendDeveloper('Alice', 3, [], 'React');
  var dev2 = BackendDeveloper('Bob', 5, [], 'PostgreSQL');

  print(dev1.toJson());

  // Future
  Future<void> simulateTask(String task) async {
    print('Starting task: $task');
    await Future.delayed(Duration(seconds: 2));
    print('Finished task: $task');
  }
  await simulateTask('Code Review');

  Future<int> calculateSalary(Developer developer) async {
    return Future.delayed(Duration(seconds: 1), () {
      return developer.calcSalary();
    });
  }
  int salary = await calculateSalary(dev1);
  print('Salary: $salary');

  // Stream
  Stream<String> singleSubscriptionStream() async* {
    yield 'Message 1';
    await Future.delayed(Duration(seconds: 1));
    yield 'Message 2';
  }

  StreamController<String> broadcastStreamController = StreamController.broadcast();

  void setupBroadcastStream() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      broadcastStreamController.add('Broadcast message at ${DateTime.now()}');
    });
  }
  setupBroadcastStream();
  broadcastStreamController.stream.listen((message) {
    print('Received: $message');
  });
}