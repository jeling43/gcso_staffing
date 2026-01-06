import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Provider for managing employees across the application
class EmployeeProvider extends ChangeNotifier {
  final List<Employee> _employees = [];
  Employee? _currentUser;

  List<Employee> get employees => List.unmodifiable(_employees);
  Employee? get currentUser => _currentUser;
  bool get isCurrentUserSupervisor => _currentUser?.isSupervisor ?? false;

  EmployeeProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Sample employees for Patrol division - 12 total
    // B Shift: 6 employees (3 Day, 3 Night)
    // A Shift: 6 employees (2 Day, 2 Night, 2 Split)
    // Swing schedule: 3 on, 2 off, 2 on, 3 off
    _employees.addAll([
      // B Shift - Day - 3 employees
      Employee(
        id: '1',
        firstName: 'J.Rex',
        lastName: 'Anderson',
        badgeNumber: '170',
        rank: Rank.sergeantFirstClass,
        isSupervisor: true,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.day,
      ),
      Employee(
        id: '2',
        firstName: 'J.D',
        lastName: 'Newport',
        badgeNumber: '103',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.day,
      ),
      Employee(
        id: '3',
        firstName: 'Emily',
        lastName: 'Brown',
        badgeNumber: 'P003',
        rank: Rank.corporal,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.day,
      ),
      // B Shift - Night - 3 employees
      Employee(
        id: '4',
        firstName: 'David',
        lastName: 'Davis',
        badgeNumber: 'P004',
        rank: Rank.lieutenant,
        isSupervisor: true,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.night,
      ),
      Employee(
        id: '5',
        firstName: 'Jessica',
        lastName: 'Miller',
        badgeNumber: 'P005',
        rank: Rank.sergeantFirstClass,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.night,
      ),
      Employee(
        id: '6',
        firstName: 'Christopher',
        lastName: 'Wilson',
        badgeNumber: 'P006',
        rank: Rank.corporal,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.night,
      ),
      // A Shift - Day - 2 employees
      Employee(
        id: '7',
        firstName: 'Amanda',
        lastName: 'Taylor',
        badgeNumber: 'P007',
        rank: Rank.lieutenant,
        isSupervisor: true,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.day,
      ),
      Employee(
        id: '8',
        firstName: 'Daniel',
        lastName: 'Anderson',
        badgeNumber: 'P008',
        rank: Rank.sergeantFirstClass,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.day,
      ),
      // A Shift - Night - 2 employees
      Employee(
        id: '9',
        firstName: 'Ashley',
        lastName: 'Thomas',
        badgeNumber: 'P009',
        rank: Rank.corporal,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.night,
      ),
      Employee(
        id: '10',
        firstName: 'James',
        lastName: 'Martinez',
        badgeNumber: 'P010',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.night,
      ),
      // A Shift - Split - 2 employees
      Employee(
        id: '11',
        firstName: 'Robert',
        lastName: 'Garcia',
        badgeNumber: 'P011',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.split1200,
      ),
      Employee(
        id: '12',
        firstName: 'Maria',
        lastName: 'Rodriguez',
        badgeNumber: 'P012',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.split1400,
      ),
    ]);

    // Set default current user as supervisor
    _currentUser = _employees.first;
  }

  void setCurrentUser(Employee? employee) {
    _currentUser = employee;
    notifyListeners();
  }

  List<Employee> getEmployeesByDivision(Division division) {
    return _employees.where((e) => e.division == division).toList();
  }

  void addEmployee(Employee employee) {
    _employees.add(employee);
    notifyListeners();
  }

  void updateEmployee(Employee employee) {
    final index = _employees.indexWhere((e) => e.id == employee.id);
    if (index != -1) {
      _employees[index] = employee;
      notifyListeners();
    }
  }

  void removeEmployee(String id) {
    _employees.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  /// Assign employee to a division. Employees can only be in one division.
  void assignToDivision(String employeeId, Division division) {
    final index = _employees.indexWhere((e) => e.id == employeeId);
    if (index != -1) {
      _employees[index] = _employees[index].copyWith(division: division);
      notifyListeners();
    }
  }
}
