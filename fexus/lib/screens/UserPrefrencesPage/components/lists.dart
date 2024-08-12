class Skill {
  final String name;

  Skill({required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Skill && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class Interest {
  final String name;

  Interest({required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Interest &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

final List<Skill> allSkills = [
  Skill(name: 'Software Development'),
  Skill(name: 'Data Science'),
  Skill(name: 'Machine Learning'),
  Skill(name: 'DevOps'),
];

final List<Interest> allInterests = [
  Interest(name: 'Healthcare'),
  Interest(name: 'Finance'),
  Interest(name: 'Education'),
];
