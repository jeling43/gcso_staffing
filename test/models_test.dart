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
      );

      final shifts = Shift.validShifts;
      
      // Should have Day, Night, Split shifts
      expect(shifts.length, equals(3));
      expect(shifts.contains(Shift.day), isTrue);
      expect(shifts.contains(Shift.night), isTrue);
      expect(shifts.contains(Shift.split), isTrue);
      
      for (final shift in shifts) {
        final entry = ScheduleEntry(
          id: 'sched_$shift',
          employee: employee,
          division: Division.patrol,
          date: DateTime(2024, 1, 15),
          shift: shift,
        );
        expect(entry.shift, equals(shift));
      }
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
}
