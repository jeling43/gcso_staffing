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
    // Sample employees for Patrol division - 11 total
    // 5 Day shift, 5 Night shift, 1 Split shift
    _employees.addAll([
      // Day Shift - 5 employees
      Employee(
        id: '1',
        firstName: 'Sarah',
        lastName: 'Johnson',
        badgeNumber: 'P001',
        rank: Rank.lieutenant,
        isSupervisor: true,
        division: Division.patrol,
      ),
      Employee(
        id: '2',
        firstName: 'Michael',
        lastName: 'Williams',
        badgeNumber: 'P002',
        rank: Rank.sergeantFirstClass,
        isSupervisor: false,
        division: Division.patrol,
      ),
      Employee(
        id: '3',
        firstName: 'Emily',
        lastName: 'Brown',
        badgeNumber: 'P003',
        rank: Rank.corporal,
        isSupervisor: false,
        division: Division.patrol,
      ),
      Employee(
        id: '4',
        firstName: 'David',
        lastName: 'Davis',
        badgeNumber: 'P004',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
      ),
      Employee(
        id: '5',
        firstName: 'Jessica',
        lastName: 'Miller',
        badgeNumber: 'P005',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
      ),
      // Night Shift - 5 employees
      Employee(
        id: '6',
        firstName: 'Christopher',
        lastName: 'Wilson',
        badgeNumber: 'P006',
        rank: Rank.lieutenant,
        isSupervisor: true,
        division: Division.patrol,
      ),
      Employee(
        id: '7',
        firstName: 'Amanda',
        lastName: 'Taylor',
        badgeNumber: 'P007',
        rank: Rank.sergeantFirstClass,
        isSupervisor: false,
        division: Division.patrol,
      ),
      Employee(
        id: '8',
        firstName: 'Daniel',
        lastName: 'Anderson',
        badgeNumber: 'P008',
        rank: Rank.corporal,
        isSupervisor: false,
        division: Division.patrol,
      ),
      Employee(
        id: '9',
        firstName: 'Ashley',
        lastName: 'Thomas',
        badgeNumber: 'P009',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
      ),
      Employee(
        id: '10',
        firstName: 'James',
        lastName: 'Martinez',
        badgeNumber: 'P010',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
      ),
      // Split Shift - 1 employee
      Employee(
        id: '11',
        firstName: 'Robert',
        lastName: 'Garcia',
        badgeNumber: 'P011',
        rank: Rank.sergeantFirstClass,
        isSupervisor: false,
        division: Division.patrol,
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
