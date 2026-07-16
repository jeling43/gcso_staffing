import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Provider for managing schedule entries
class ScheduleProvider extends ChangeNotifier {
  final List<ScheduleEntry> _scheduleEntries = [];
  final Set<String> _generatedDateKeys = {};
  Set<String>? _absentEntryIds;
  List<Employee> _employees;

  Set<String> get _absences => _absentEntryIds ??= <String>{};

  List<ScheduleEntry> get scheduleEntries =>
      List.unmodifiable(_effectiveEntries());

  ScheduleProvider(List<Employee> employees)
      : _employees = List<Employee>.of(employees) {
    _ensureScheduleForDate(DateTime.now());
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void updateEmployees(List<Employee> employees) {
    _employees = List<Employee>.of(employees);
    final employeesById = {
      for (final employee in _employees) employee.id: employee
    };

    _scheduleEntries.removeWhere((entry) {
      if (entry.isTemporary) {
        return false;
      }
      final currentEmployee = employeesById[entry.employee.id];
      return currentEmployee == null ||
          currentEmployee.shiftGroup !=
              ShiftGroup.getWorkingShiftGroup(entry.date);
    });

    // Revisit generated dates so newly eligible employees are added from the
    // current hard-coded roster. Date-specific temporary overrides remain.
    _generatedDateKeys.clear();
  }

  /// Pre-generate an inclusive date range when needed by an administrative
  /// workflow. Normal date navigation generates individual dates on demand.
  int generateScheduleRange(DateTime startDate, DateTime endDate) {
    final start = _dateOnly(startDate);
    final end = _dateOnly(endDate);
    if (end.isBefore(start)) {
      return 0;
    }

    final entriesBefore = _scheduleEntries.length;
    for (var date = start;
        !date.isAfter(end);
        date = date.add(const Duration(days: 1))) {
      _ensureScheduleForDate(date);
    }

    final entriesCreated = _scheduleEntries.length - entriesBefore;
    notifyListeners();
    return entriesCreated;
  }

  void _ensureScheduleForDate(DateTime date) {
    final dateKey = _dateKey(date);
    if (_generatedDateKeys.contains(dateKey)) {
      return;
    }

    final normalizedDate = _dateOnly(date);
    final workingShiftGroup = ShiftGroup.getWorkingShiftGroup(normalizedDate);
    final existingEmployeeIds = _scheduleEntries
        .where((entry) => _dateKey(entry.date) == dateKey)
        .map((entry) => entry.employee.id)
        .toSet();

    for (final employee in _employees) {
      if (employee.division == null ||
          employee.shiftGroup != workingShiftGroup ||
          employee.shiftType == null ||
          existingEmployeeIds.contains(employee.id)) {
        continue;
      }

      _scheduleEntries.add(
        ScheduleEntry(
          id: 'sched_${employee.id}_$dateKey',
          employee: employee,
          division: employee.division!,
          date: normalizedDate,
          shift: employee.shiftType!,
          isOnDuty: true,
          isTemporary: false,
        ),
      );
    }

    _generatedDateKeys.add(dateKey);
  }

  List<ScheduleEntry> _effectiveEntries() {
    final employeesById = {
      for (final employee in _employees) employee.id: employee
    };
    final entries = <ScheduleEntry>[];

    for (final entry in _scheduleEntries) {
      final currentEmployee = employeesById[entry.employee.id];
      if (!entry.isTemporary &&
          (currentEmployee == null ||
              currentEmployee.shiftGroup !=
                  ShiftGroup.getWorkingShiftGroup(entry.date))) {
        continue;
      }

      var effectiveEntry = currentEmployee == null
          ? entry
          : entry.copyWith(
              employee: currentEmployee,
              division: currentEmployee.division ?? entry.division,
            );
      if (_absences.contains(entry.id)) {
        effectiveEntry = effectiveEntry.copyWith(isOnDuty: false);
      }
      entries.add(effectiveEntry);
    }

    entries.sort(
      (first, second) => Employee.compareByRankThenBadge(
        first.employee,
        second.employee,
      ),
    );
    return entries;
  }

  List<ScheduleEntry> getScheduleForDate(DateTime date) {
    _ensureScheduleForDate(date);
    return _effectiveEntries()
        .where((entry) =>
            entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day)
        .toList();
  }

  List<ScheduleEntry> getScheduleByDivision(Division division,
      {DateTime? date}) {
    if (date != null) {
      _ensureScheduleForDate(date);
    }
    var entries = _effectiveEntries().where((e) => e.division == division);
    if (date != null) {
      entries = entries.where((entry) =>
          entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day);
    }
    return entries.toList();
  }

  List<ScheduleEntry> getCurrentlyOnDuty(Division division) {
    final today = DateTime.now();
    _ensureScheduleForDate(today);
    return _effectiveEntries()
        .where((entry) =>
            entry.division == division &&
            entry.isOnDuty &&
            entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day)
        .toList();
  }

  List<ScheduleEntry> getScheduleByShift(String shift, {DateTime? date}) {
    if (date != null) {
      _ensureScheduleForDate(date);
    }
    var entries = _effectiveEntries().where((e) => e.shift == shift);
    if (date != null) {
      entries = entries.where((entry) =>
          entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day);
    }
    return entries.toList();
  }

  List<ScheduleEntry> getCurrentlyOnDutyByShift(String shift) {
    final today = DateTime.now();
    _ensureScheduleForDate(today);
    return _effectiveEntries()
        .where((entry) =>
            entry.shift == shift &&
            entry.isOnDuty &&
            entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day)
        .toList();
  }

  void addScheduleEntry(ScheduleEntry entry) {
    _scheduleEntries.add(entry);
    notifyListeners();
  }

  void updateScheduleEntry(ScheduleEntry entry) {
    final index = _scheduleEntries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _scheduleEntries[index] =
          _absences.contains(entry.id) ? entry.copyWith(isOnDuty: true) : entry;
      notifyListeners();
    }
  }

  void removeScheduleEntry(String id) {
    _scheduleEntries.removeWhere((e) => e.id == id);
    _absences.remove(id);
    notifyListeners();
  }

  /// Toggle the on-duty status of a schedule entry
  void toggleOnDutyStatus(String id) {
    final index = _scheduleEntries.indexWhere((e) => e.id == id);
    if (index != -1) {
      if (_absences.contains(id)) {
        _absences.remove(id);
      } else {
        _absences.add(id);
      }
      notifyListeners();
    }
  }

  /// Mark an employee as absent or present for a specific schedule entry
  /// This is a more explicit method than toggleOnDutyStatus for marking absences
  void markEmployeeAbsent(String scheduleEntryId, bool isAbsent) {
    final index = _scheduleEntries.indexWhere((e) => e.id == scheduleEntryId);
    if (index != -1) {
      if (isAbsent) {
        _absences.add(scheduleEntryId);
      } else {
        _absences.remove(scheduleEntryId);
      }
      notifyListeners();
    }
  }

  /// Check if a person can be added to a split shift
  /// Split shifts (Split-1200 and Split-1400) have a maximum capacity of 1 person
  bool canAddToSplit(String shift, DateTime date, Division division) {
    // No restriction for non-split shifts
    if (shift != Shift.split1200 && shift != Shift.split1400) {
      return true;
    }

    // For split shifts, check if there's already one person assigned
    _ensureScheduleForDate(date);
    final existingCount = _effectiveEntries()
        .where((entry) =>
            entry.shift == shift &&
            entry.division == division &&
            entry.isOnDuty &&
            entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day)
        .length;

    return existingCount < 1;
  }
}
