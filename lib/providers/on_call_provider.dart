import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Provider for managing on-call assignments
class OnCallProvider extends ChangeNotifier {
  final List<OnCallAssignment> _onCallAssignments = [];

  List<OnCallAssignment> get onCallAssignments =>
      List.unmodifiable(_onCallAssignments);

  OnCallProvider(List<Employee> employees) {
    _initializeSampleOnCallData(employees);
  }

  void _initializeSampleOnCallData(List<Employee> employees) {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Assign one on-call person per division for this week
    for (final division in Division.values) {
      final divisionEmployees =
          employees.where((e) => e.division == division).toList();
      if (divisionEmployees.isNotEmpty) {
        _onCallAssignments.add(OnCallAssignment(
          id: 'oncall_${division.name}_${weekStart.toIso8601String()}',
          employee: divisionEmployees.first,
          division: division,
          startDate: weekStart,
          endDate: weekEnd,
          notes: 'Weekly on-call rotation',
        ));
      }
    }
  }

  List<OnCallAssignment> getActiveOnCallAssignments({DateTime? date}) {
    final checkDate = date ?? DateTime.now();
    return _onCallAssignments
        .where((assignment) => assignment.isActiveOn(checkDate))
        .toList();
  }

  OnCallAssignment? getOnCallForDivision(Division division, {DateTime? date}) {
    final checkDate = date ?? DateTime.now();
    try {
      return _onCallAssignments.firstWhere(
        (assignment) =>
            assignment.division == division && assignment.isActiveOn(checkDate),
      );
    } catch (e) {
      return null;
    }
  }

  List<OnCallAssignment> getOnCallByDivision(Division division) {
    return _onCallAssignments
        .where((assignment) => assignment.division == division)
        .toList();
  }

  void addOnCallAssignment(OnCallAssignment assignment) {
    _onCallAssignments.add(assignment);
    notifyListeners();
  }

  void updateOnCallAssignment(OnCallAssignment assignment) {
    final index = _onCallAssignments.indexWhere((a) => a.id == assignment.id);
    if (index != -1) {
      _onCallAssignments[index] = assignment;
      notifyListeners();
    }
  }

  void removeOnCallAssignment(String id) {
    _onCallAssignments.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
