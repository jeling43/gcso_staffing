import 'division.dart';

/// Valid rank values for employees
class Rank {
  static const String lieutenant = 'LT';
  static const String sergeantFirstClass = 'SFC';
  static const String corporal = 'CPL';
  static const String deputy = 'DEP';
  
  static const List<String> validRanks = [lieutenant, sergeantFirstClass, corporal, deputy];
}

/// Valid shift names
class Shift {
  static const String day = 'Day';
  static const String night = 'Night';
  static const String split = 'Split';
  
  static const List<String> validShifts = [day, night, split];
}

/// Represents an employee in the Sheriff's Office
class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String badgeNumber;
  final String rank; // "LT", "SFC", "DEP"
  final bool isSupervisor;
  final Division? division; // Employees can only be assigned to one division

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.badgeNumber,
    required this.rank,
    this.isSupervisor = false,
    this.division,
  }) : assert(Rank.validRanks.contains(rank), 'Invalid rank: $rank');

  String get fullName => '$firstName $lastName';

  Employee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? badgeNumber,
    String? rank,
    bool? isSupervisor,
    Division? division,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      rank: rank ?? this.rank,
      isSupervisor: isSupervisor ?? this.isSupervisor,
      division: division ?? this.division,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
