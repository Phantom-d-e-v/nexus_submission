class Career {
  final String name;

  Career({required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Career && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

final List<Career> allCareers = [
  Career(name: 'Software Engineer'),
  Career(name: 'Data Scientist'),
  Career(name: 'Machine Learning Engineer'),
  Career(name: 'DevOps Engineer'),
  Career(name: 'Product Manager'),
  Career(name: 'Business Analyst'),
  Career(name: 'Healthcare Consultant'),
  Career(name: 'Financial Analyst'),
];
