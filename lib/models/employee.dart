import 'division.dart';

/// Represents an employee in the Sheriff's Office
class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String badgeNumber;
  final bool isSupervisor;
  Division? division; // Employees can only be assigned to one division

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.badgeNumber,
    this.isSupervisor = false,
    this.division,
  });

  String get fullName => '$firstName $lastName';

  Employee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? badgeNumber,
    bool? isSupervisor,
    Division? division,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      badgeNumber: badgeNumber ?? this.badgeNumber,
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
