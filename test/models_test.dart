import 'package:flutter_test/flutter_test.dart';
import 'package:gcso_staffing/models/models.dart';
import 'package:gcso_staffing/providers/providers.dart';

void main() {
  group('Division', () {
    test('has correct display names', () {
      expect(Division.patrol.displayName, equals('Patrol'));
    });
    
    test('only has patrol division', () {
      expect(Division.values.length, equals(1));
      expect(Division.values.first, equals(Division.patrol));
    });
  });

  group('Employee', () {
    test('creates employee with required fields', () {
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
        rank: Rank.deputy,
      );

      expect(employee.id, equals('1'));
      expect(employee.firstName, equals('John'));
      expect(employee.lastName, equals('Doe'));
      expect(employee.badgeNumber, equals('B001'));
      expect(employee.rank, equals(Rank.deputy));
      expect(employee.isSupervisor, isFalse);
      expect(employee.division, isNull);
    });

    test('fullName returns correct format', () {
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
        rank: Rank.deputy,
      );

      expect(employee.fullName, equals('John Doe'));
    });

    test('supports different rank values', () {
      final lt = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
        rank: Rank.lieutenant,
      );
      final sfc = Employee(
        id: '2',
        firstName: 'Jane',
        lastName: 'Smith',
        badgeNumber: 'B002',
        rank: Rank.sergeantFirstClass,
      );
      final dep = Employee(
        id: '3',
        firstName: 'Bob',
        lastName: 'Johnson',
        badgeNumber: 'B003',
        rank: Rank.deputy,
      );

      expect(lt.rank, equals(Rank.lieutenant));
      expect(sfc.rank, equals(Rank.sergeantFirstClass));
      expect(dep.rank, equals(Rank.deputy));
    });

    test('employees are assigned to patrol division', () {
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
        rank: Rank.deputy,
        division: Division.patrol,
      );

      // Employee is assigned to patrol
      expect(employee.division, equals(Division.patrol));
    });

    test('copyWith creates new employee with updated fields', () {
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
        rank: Rank.deputy,
        division: Division.patrol,
      );

      final updated = employee.copyWith(
        firstName: 'Jane',
        rank: Rank.lieutenant,
        isSupervisor: true,
      );

      expect(updated.id, equals('1'));
      expect(updated.firstName, equals('Jane'));
      expect(updated.lastName, equals('Doe'));
      expect(updated.rank, equals(Rank.lieutenant));
      expect(updated.isSupervisor, isTrue);
    });
  });

  group('ScheduleEntry', () {
    test('creates schedule entry with required fields', () {
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
        rank: Rank.deputy,
        division: Division.patrol,
      );

      final entry = ScheduleEntry(
        id: 'sched1',
        employee: employee,
        division: Division.patrol,
        date: DateTime(2024, 1, 15),
        shift: Shift.day,
      );

      expect(entry.id, equals('sched1'));
      expect(entry.employee, equals(employee));
      expect(entry.division, equals(Division.patrol));
      expect(entry.shift, equals(Shift.day));
      expect(entry.isOnDuty, isTrue);
    });

    test('supports new shift naming convention', () {
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
        rank: Rank.deputy,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
      );

      final shifts = Shift.validShifts;
      
      // Should have 8 shifts (4 for group A, 4 for group B)
      expect(shifts.length, equals(8));
      expect(shifts.contains(Shift.aDays), isTrue);
      expect(shifts.contains(Shift.aSplit1200), isTrue);
      expect(shifts.contains(Shift.aSplit1400), isTrue);
      expect(shifts.contains(Shift.aNight), isTrue);
      expect(shifts.contains(Shift.bDays), isTrue);
      expect(shifts.contains(Shift.bSplit1200), isTrue);
      expect(shifts.contains(Shift.bSplit1400), isTrue);
      expect(shifts.contains(Shift.bNight), isTrue);
      
      // Test creating schedule entries with the base shift types
      final dayEntry = ScheduleEntry(
        id: 'sched_day',
        employee: employee,
        division: Division.patrol,
        date: DateTime(2024, 1, 15),
        shift: Shift.day,
      );
      expect(dayEntry.shift, equals(Shift.day));
      
      final split1200Entry = ScheduleEntry(
        id: 'sched_split1200',
        employee: employee,
        division: Division.patrol,
        date: DateTime(2024, 1, 15),
        shift: Shift.split1200,
      );
      expect(split1200Entry.shift, equals(Shift.split1200));
      
      final split1400Entry = ScheduleEntry(
        id: 'sched_split1400',
        employee: employee,
        division: Division.patrol,
        date: DateTime(2024, 1, 15),
        shift: Shift.split1400,
      );
      expect(split1400Entry.shift, equals(Shift.split1400));
    });
    
    test('getDisplayName returns user-friendly names', () {
      expect(Shift.getDisplayName(Shift.aDays), equals('Days Shift (A) - 06:00-18:00'));
      expect(Shift.getDisplayName(Shift.aSplit1200), equals('Split Shift 1200 (A) - 12:00-24:00'));
      expect(Shift.getDisplayName(Shift.aSplit1400), equals('Split Shift 1400 (A) - 14:00-02:00'));
      expect(Shift.getDisplayName(Shift.aNight), equals('Night Shift (A) - 18:00-06:00'));
      expect(Shift.getDisplayName(Shift.bDays), equals('Days Shift (B) - 06:00-18:00'));
      expect(Shift.getDisplayName(Shift.bSplit1200), equals('Split Shift 1200 (B) - 12:00-24:00'));
      expect(Shift.getDisplayName(Shift.bSplit1400), equals('Split Shift 1400 (B) - 14:00-02:00'));
      expect(Shift.getDisplayName(Shift.bNight), equals('Night Shift (B) - 18:00-06:00'));
      
      // Test fallback for base shift types
      expect(Shift.getDisplayName(Shift.day), equals('Days Shift - 06:00-18:00'));
      expect(Shift.getDisplayName(Shift.night), equals('Night Shift - 18:00-06:00'));
      expect(Shift.getDisplayName(Shift.split1200), equals('Split Shift 1200 - 12:00-24:00'));
      expect(Shift.getDisplayName(Shift.split1400), equals('Split Shift 1400 - 14:00-02:00'));
    });
    
    test('swing schedule calculates correctly', () {
      // A shift starts Jan 5, 2026 (Monday)
      final aStart = DateTime(2026, 1, 5);
      
      // Day 0 (Jan 5) - A working
      expect(ShiftGroup.getWorkingShiftGroup(aStart), equals(ShiftGroup.a));
      
      // Day 1 (Jan 6) - A working
      expect(ShiftGroup.getWorkingShiftGroup(aStart.add(const Duration(days: 1))), equals(ShiftGroup.a));
      
      // Day 2 (Jan 7) - B working
      expect(ShiftGroup.getWorkingShiftGroup(aStart.add(const Duration(days: 2))), equals(ShiftGroup.b));
      
      // Day 3 (Jan 8) - B working
      expect(ShiftGroup.getWorkingShiftGroup(aStart.add(const Duration(days: 3))), equals(ShiftGroup.b));
      
      // Day 4 (Jan 9) - A working
      expect(ShiftGroup.getWorkingShiftGroup(aStart.add(const Duration(days: 4))), equals(ShiftGroup.a));
      
      // Day 5 (Jan 10) - A working
      expect(ShiftGroup.getWorkingShiftGroup(aStart.add(const Duration(days: 5))), equals(ShiftGroup.a));
      
      // Day 6 (Jan 11) - A working
      expect(ShiftGroup.getWorkingShiftGroup(aStart.add(const Duration(days: 6))), equals(ShiftGroup.a));
      
      // Day 7 (Jan 12) - B working
      expect(ShiftGroup.getWorkingShiftGroup(aStart.add(const Duration(days: 7))), equals(ShiftGroup.b));
      
      // Day 8 (Jan 13) - B working
      expect(ShiftGroup.getWorkingShiftGroup(aStart.add(const Duration(days: 8))), equals(ShiftGroup.b));
      
      // Day 9 (Jan 14) - B working
      expect(ShiftGroup.getWorkingShiftGroup(aStart.add(const Duration(days: 9))), equals(ShiftGroup.b));
      
      // Day 10 (Jan 15) - A working (start of new cycle)
      expect(ShiftGroup.getWorkingShiftGroup(aStart.add(const Duration(days: 10))), equals(ShiftGroup.a));
    });
  });

  group('EmployeeProvider', () {
    test('initializes with 12 patrol employees', () {
      final provider = EmployeeProvider();
      
      expect(provider.employees.length, equals(12));
      expect(provider.currentUser, isNotNull);
    });
    
    test('all sample employees are in patrol division', () {
      final provider = EmployeeProvider();
      
      for (final employee in provider.employees) {
        expect(employee.division, equals(Division.patrol));
      }
    });
    
    test('all sample employees have shift groups', () {
      final provider = EmployeeProvider();
      
      for (final employee in provider.employees) {
        expect(employee.shiftGroup, isNotNull);
        expect(ShiftGroup.validGroups.contains(employee.shiftGroup), isTrue);
      }
    });
    
    test('shift groups are balanced', () {
      final provider = EmployeeProvider();
      
      final bEmployees = provider.employees.where((e) => e.shiftGroup == ShiftGroup.b).toList();
      final aEmployees = provider.employees.where((e) => e.shiftGroup == ShiftGroup.a).toList();
      
      expect(bEmployees.length, equals(6));
      expect(aEmployees.length, equals(6));
    });

    test('all sample employees have ranks', () {
      final provider = EmployeeProvider();
      
      for (final employee in provider.employees) {
        expect(employee.rank, isNotEmpty);
        expect(Rank.validRanks.contains(employee.rank), isTrue);
      }
    });

    test('can filter employees by division', () {
      final provider = EmployeeProvider();
      
      final patrolEmployees = provider.getEmployeesByDivision(Division.patrol);
      
      expect(patrolEmployees.length, equals(12));
      for (final employee in patrolEmployees) {
        expect(employee.division, equals(Division.patrol));
      }
    });

    test('assignToDivision updates employee division', () {
      final provider = EmployeeProvider();
      final employee = provider.employees.first;
      
      // Already in patrol, just verify
      expect(employee.division, equals(Division.patrol));
      
      provider.assignToDivision(employee.id, Division.patrol);
      
      final updatedEmployee = provider.employees.firstWhere((e) => e.id == employee.id);
      expect(updatedEmployee.division, equals(Division.patrol));
    });
  });

  group('ScheduleProvider', () {
    test('canAddToSplit allows non-split shifts', () {
      final employeeProvider = EmployeeProvider();
      final scheduleProvider = ScheduleProvider(employeeProvider.employees);
      final today = DateTime.now();
      
      // Non-split shifts should always return true
      expect(scheduleProvider.canAddToSplit(Shift.day, today, Division.patrol), isTrue);
      expect(scheduleProvider.canAddToSplit(Shift.night, today, Division.patrol), isTrue);
    });
    
    test('canAddToSplit enforces 1-person limit for split shifts', () {
      final employeeProvider = EmployeeProvider();
      final scheduleProvider = ScheduleProvider(employeeProvider.employees);
      final today = DateTime.now();
      
      // Get current on-duty split shift staff
      final split1200Staff = scheduleProvider.getCurrentlyOnDutyByShift(Shift.split1200);
      final split1400Staff = scheduleProvider.getCurrentlyOnDutyByShift(Shift.split1400);
      
      // If no one is on split1200, should be able to add
      if (split1200Staff.isEmpty) {
        expect(scheduleProvider.canAddToSplit(Shift.split1200, today, Division.patrol), isTrue);
      } else {
        // If someone is already on split1200, should not be able to add
        expect(scheduleProvider.canAddToSplit(Shift.split1200, today, Division.patrol), isFalse);
      }
      
      // Same for split1400
      if (split1400Staff.isEmpty) {
        expect(scheduleProvider.canAddToSplit(Shift.split1400, today, Division.patrol), isTrue);
      } else {
        expect(scheduleProvider.canAddToSplit(Shift.split1400, today, Division.patrol), isFalse);
      }
    });
  });
}
