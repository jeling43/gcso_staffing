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
    // Sample employees for demo
    _employees.addAll([
      Employee(
        id: '1',
        firstName: 'John',
        lastName: 'Smith',
        badgeNumber: 'J001',
        rank: 'LT',
        isSupervisor: true,
        division: Division.jail,
      ),
      Employee(
        id: '2',
        firstName: 'Sarah',
        lastName: 'Johnson',
        badgeNumber: 'P001',
        rank: 'LT',
        isSupervisor: true,
        division: Division.patrol,
      ),
      Employee(
        id: '3',
        firstName: 'Michael',
        lastName: 'Williams',
        badgeNumber: 'C001',
        rank: 'LT',
        isSupervisor: true,
        division: Division.courthouse,
      ),
      Employee(
        id: '4',
        firstName: 'Emily',
        lastName: 'Brown',
        badgeNumber: 'J002',
        rank: 'SFC',
        isSupervisor: false,
        division: Division.jail,
      ),
      Employee(
        id: '5',
        firstName: 'David',
        lastName: 'Davis',
        badgeNumber: 'J003',
        rank: 'DEP',
        isSupervisor: false,
        division: Division.jail,
      ),
      Employee(
        id: '6',
        firstName: 'Jessica',
        lastName: 'Miller',
        badgeNumber: 'P002',
        rank: 'SFC',
        isSupervisor: false,
        division: Division.patrol,
      ),
      Employee(
        id: '7',
        firstName: 'Christopher',
        lastName: 'Wilson',
        badgeNumber: 'P003',
        rank: 'DEP',
        isSupervisor: false,
        division: Division.patrol,
      ),
      Employee(
        id: '8',
        firstName: 'Amanda',
        lastName: 'Taylor',
        badgeNumber: 'C002',
        rank: 'SFC',
        isSupervisor: false,
        division: Division.courthouse,
      ),
      Employee(
        id: '9',
        firstName: 'Daniel',
        lastName: 'Anderson',
        badgeNumber: 'C003',
        rank: 'DEP',
        isSupervisor: false,
        division: Division.courthouse,
      ),
      Employee(
        id: '10',
        firstName: 'Ashley',
        lastName: 'Thomas',
        badgeNumber: 'P004',
        rank: 'DEP',
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
