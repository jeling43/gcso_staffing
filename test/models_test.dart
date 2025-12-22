import 'package:flutter_test/flutter_test.dart';
import 'package:gcso_staffing/models/models.dart';
import 'package:gcso_staffing/providers/providers.dart';

void main() {
  group('Division', () {
    test('has correct display names', () {
      expect(Division.jail.displayName, equals('Jail'));
      expect(Division.patrol.displayName, equals('Patrol'));
      expect(Division.courthouse.displayName, equals('Courthouse'));
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

    test('employees can only be assigned to one division', () {
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
        rank: Rank.deputy,
        division: Division.jail,
      );

      // Employee is assigned to jail
      expect(employee.division, equals(Division.jail));

      // When reassigned to patrol, they are no longer in jail
      final reassignedEmployee = employee.copyWith(division: Division.patrol);
      expect(reassignedEmployee.division, equals(Division.patrol));
    });

    test('copyWith creates new employee with updated fields', () {
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
        rank: Rank.deputy,
        division: Division.jail,
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
        division: Division.jail,
      );

      final entry = ScheduleEntry(
        id: 'sched1',
        employee: employee,
        division: Division.jail,
        date: DateTime(2024, 1, 15),
        shift: Shift.aDays,
      );

      expect(entry.id, equals('sched1'));
      expect(entry.employee, equals(employee));
      expect(entry.division, equals(Division.jail));
      expect(entry.shift, equals(Shift.aDays));
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
    test('initializes with sample employees', () {
      final provider = EmployeeProvider();
      
      expect(provider.employees.isNotEmpty, isTrue);
      expect(provider.currentUser, isNotNull);
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
      
      final jailEmployees = provider.getEmployeesByDivision(Division.jail);
      
      for (final employee in jailEmployees) {
        expect(employee.division, equals(Division.jail));
      }
    });

    test('assignToDivision updates employee division', () {
      final provider = EmployeeProvider();
      final employee = provider.employees.first;
      
      provider.assignToDivision(employee.id, Division.courthouse);
      
      final updatedEmployee = provider.employees.firstWhere((e) => e.id == employee.id);
      expect(updatedEmployee.division, equals(Division.courthouse));
    });

    test('employee can only belong to one division at a time', () {
      final provider = EmployeeProvider();
      final employee = provider.employees.first;
      
      // Assign to jail
      provider.assignToDivision(employee.id, Division.jail);
      var updatedEmployee = provider.employees.firstWhere((e) => e.id == employee.id);
      expect(updatedEmployee.division, equals(Division.jail));
      
      // Reassign to patrol - should no longer be in jail
      provider.assignToDivision(employee.id, Division.patrol);
      updatedEmployee = provider.employees.firstWhere((e) => e.id == employee.id);
      expect(updatedEmployee.division, equals(Division.patrol));
      
      // Verify not in jail anymore
      final jailEmployees = provider.getEmployeesByDivision(Division.jail);
      expect(jailEmployees.any((e) => e.id == employee.id), isFalse);
      
      // Verify in patrol
      final patrolEmployees = provider.getEmployeesByDivision(Division.patrol);
      expect(patrolEmployees.any((e) => e.id == employee.id), isTrue);
    });
  });
}
