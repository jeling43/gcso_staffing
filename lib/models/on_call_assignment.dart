import 'division.dart';
import 'employee.dart';

/// Represents an on-call assignment for a specific division
class OnCallAssignment {
  final String id;
  final Employee employee;
  final Division division;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;

  OnCallAssignment({
    required this.id,
    required this.employee,
    required this.division,
    required this.startDate,
    required this.endDate,
    this.notes,
  });

  bool isActiveOn(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(endDate.add(const Duration(days: 1)));
  }

  OnCallAssignment copyWith({
    String? id,
    Employee? employee,
    Division? division,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) {
    return OnCallAssignment(
      id: id ?? this.id,
      employee: employee ?? this.employee,
      division: division ?? this.division,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnCallAssignment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
