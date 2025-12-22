import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Provider for managing schedule entries
class ScheduleProvider extends ChangeNotifier {
  final List<ScheduleEntry> _scheduleEntries = [];

  List<ScheduleEntry> get scheduleEntries => List.unmodifiable(_scheduleEntries);

  ScheduleProvider(List<Employee> employees) {
    _initializeSampleSchedule(employees);
  }

  void _initializeSampleSchedule(List<Employee> employees) {
    final today = DateTime.now();
    
    // Determine which shift group is working today based on swing schedule
    final workingShiftGroup = ShiftGroup.getWorkingShiftGroup(today);
    
    // Assign shifts based on employee ID and shift group
    // B Shift: IDs 1-3 (Day), IDs 4-6 (Night)
    // A Shift: IDs 7-8 (Day), IDs 9-10 (Night), ID 11 (Split-1200), ID 12 (Split-1400)
    for (final employee in employees) {
      if (employee.division != null && employee.shiftGroup != null) {
        String shift;
        final id = int.parse(employee.id);
        
        // Determine shift type based on employee ID
        if (id >= 1 && id <= 3) {
          shift = Shift.day;
        } else if (id >= 4 && id <= 6) {
          shift = Shift.night;
        } else if (id >= 7 && id <= 8) {
          shift = Shift.day;
        } else if (id >= 9 && id <= 10) {
          shift = Shift.night;
        } else if (id == 11) {
          shift = Shift.split1200;
        } else {
          shift = Shift.split1400;
        }
        
        // Only add schedule entry if this employee's shift group is working today
        final isWorking = employee.shiftGroup == workingShiftGroup;
        
        _scheduleEntries.add(ScheduleEntry(
          id: 'sched_${employee.id}_${today.toIso8601String()}',
          employee: employee,
          division: employee.division!,
          date: today,
          shift: shift,
          isOnDuty: isWorking,
        ));
      }
    }
  }

  List<ScheduleEntry> getScheduleForDate(DateTime date) {
    return _scheduleEntries
        .where((entry) =>
            entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day)
        .toList();
  }

  List<ScheduleEntry> getScheduleByDivision(Division division, {DateTime? date}) {
    var entries = _scheduleEntries.where((e) => e.division == division);
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
    return _scheduleEntries
        .where((entry) =>
            entry.division == division &&
            entry.isOnDuty &&
            entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day)
        .toList();
  }

  List<ScheduleEntry> getScheduleByShift(String shift, {DateTime? date}) {
    var entries = _scheduleEntries.where((e) => e.shift == shift);
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
    return _scheduleEntries
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
      _scheduleEntries[index] = entry;
      notifyListeners();
    }
  }

  void removeScheduleEntry(String id) {
    _scheduleEntries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void toggleOnDutyStatus(String id) {
    final index = _scheduleEntries.indexWhere((e) => e.id == id);
    if (index != -1) {
      final entry = _scheduleEntries[index];
      _scheduleEntries[index] = entry.copyWith(isOnDuty: !entry.isOnDuty);
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
    final existingCount = _scheduleEntries
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
