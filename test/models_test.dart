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
      );

      expect(employee.id, equals('1'));
      expect(employee.firstName, equals('John'));
      expect(employee.lastName, equals('Doe'));
      expect(employee.badgeNumber, equals('B001'));
      expect(employee.isSupervisor, isFalse);
      expect(employee.division, isNull);
    });

    test('fullName returns correct format', () {
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
      );

      expect(employee.fullName, equals('John Doe'));
    });

    test('employees can only be assigned to one division', () {
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
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
        division: Division.jail,
      );

      final updated = employee.copyWith(
        firstName: 'Jane',
        isSupervisor: true,
      );

      expect(updated.id, equals('1'));
      expect(updated.firstName, equals('Jane'));
      expect(updated.lastName, equals('Doe'));
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
        division: Division.jail,
      );

      final entry = ScheduleEntry(
        id: 'sched1',
        employee: employee,
        division: Division.jail,
        date: DateTime(2024, 1, 15),
        shift: 'Day',
      );

      expect(entry.id, equals('sched1'));
      expect(entry.employee, equals(employee));
      expect(entry.division, equals(Division.jail));
      expect(entry.shift, equals('Day'));
      expect(entry.isOnDuty, isTrue);
    });
  });

  group('OnCallAssignment', () {
    test('isActiveOn returns true for dates within range', () {
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
        division: Division.patrol,
      );

      final assignment = OnCallAssignment(
        id: 'oncall1',
        employee: employee,
        division: Division.patrol,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 7),
      );

      expect(assignment.isActiveOn(DateTime(2024, 1, 3)), isTrue);
      expect(assignment.isActiveOn(DateTime(2024, 1, 1)), isTrue);
      expect(assignment.isActiveOn(DateTime(2024, 1, 7)), isTrue);
    });

    test('isActiveOn returns false for dates outside range', () {
      final employee = Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        badgeNumber: 'B001',
        division: Division.patrol,
      );

      final assignment = OnCallAssignment(
        id: 'oncall1',
        employee: employee,
        division: Division.patrol,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 7),
      );

      expect(assignment.isActiveOn(DateTime(2023, 12, 31)), isFalse);
      expect(assignment.isActiveOn(DateTime(2024, 1, 9)), isFalse);
    });
  });

  group('EmployeeProvider', () {
    test('initializes with sample employees', () {
      final provider = EmployeeProvider();
      
      expect(provider.employees.isNotEmpty, isTrue);
      expect(provider.currentUser, isNotNull);
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
