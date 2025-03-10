abstract class IDeveloper {
  String getRole();
  int calcSalary();
}

abstract class DeveloperRole {
  void writeCode();
  void solveProblems();
}

class Developer extends DeveloperRole {
  String name;
  int _experience;
  List<String> skills;
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

  void learnSkill({required String skill}) {
    skills.add(skill);
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

void main() {
  try {
    var developers = <Developer>[];

    var frontend = FrontendDeveloper('John', 3, ['JavaScript', 'React'], 'React');
    var backend = BackendDeveloper('Alice', 5, ['Python', 'Django'], 'PostgreSQL');

    developers.add(frontend);
    developers.add(backend);

    // Working with collections
    var skillSet = <String>{};
    for (var dev in developers) {
      skillSet.addAll(dev.skills);
    }

    print('Unique skills: $skillSet');

    // continue and break
    for (var i = 0; i < developers.length; i++) {
      if (developers[i] is BackendDeveloper) {
        continue;
      }
      developers[i].writeCode();
      if (i >= 0) {
        break;
      }
    }

    // exception handling
    try {
      frontend.experience = -1;
    } catch (e) {
      print('Invalid experience value');
    }
  }
  catch (e) {
    print('An error occurred: $e');
  }
}