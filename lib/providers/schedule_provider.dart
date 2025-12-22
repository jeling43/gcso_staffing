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
    final shifts = ['A-Days', 'A-Split', 'A-Night', 'B-Days', 'B-Split', 'B-Night'];
    
    for (final employee in employees) {
      if (employee.division != null) {
        _scheduleEntries.add(ScheduleEntry(
          id: 'sched_${employee.id}_${today.toIso8601String()}',
          employee: employee,
          division: employee.division!,
          date: today,
          shift: shifts[int.parse(employee.id) % shifts.length],
          isOnDuty: true,
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
}
