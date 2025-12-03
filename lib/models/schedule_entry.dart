import 'division.dart';
import 'employee.dart';

/// Represents a schedule entry for an employee
class ScheduleEntry {
  final String id;
  final Employee employee;
  final Division division;
  final DateTime date;
  final String shift; // e.g., "Day", "Night", "Swing"
  final bool isOnDuty;

  ScheduleEntry({
    required this.id,
    required this.employee,
    required this.division,
    required this.date,
    required this.shift,
    this.isOnDuty = true,
  });

  ScheduleEntry copyWith({
    String? id,
    Employee? employee,
    Division? division,
    DateTime? date,
    String? shift,
    bool? isOnDuty,
  }) {
    return ScheduleEntry(
      id: id ?? this.id,
      employee: employee ?? this.employee,
      division: division ?? this.division,
      date: date ?? this.date,
      shift: shift ?? this.shift,
      isOnDuty: isOnDuty ?? this.isOnDuty,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
