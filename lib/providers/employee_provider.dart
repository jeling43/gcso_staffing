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
    // GCSO Patrol Division Roster - Effective 12/23/2025
    // 39 total employees across all shifts
    _employees.addAll([
      // A-DAY (0600-1800) - 5 employees
      Employee(
        id: '122',
        firstName: 'R.C.',
        lastName: 'GARCIA',
        badgeNumber: '122',
        rank: Rank.sergeantFirstClass,
        isSupervisor: true,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '116',
        firstName: 'M.A.',
        lastName: 'FLIPPEN',
        badgeNumber: '116',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.day,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '135',
        firstName: 'D.B.',
        lastName: 'LACKEY',
        badgeNumber: '135',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.day,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '158',
        firstName: 'J.L.',
        lastName: 'HOLCOMBE',
        badgeNumber: '158',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.day,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '171',
        firstName: 'J. RICHIE',
        lastName: 'ANDERSON',
        badgeNumber: '171',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.day,
        employmentStatus: EmploymentStatus.fullTime,
      ),

      // B-DAY (0600-1800) - 5 employees
      Employee(
        id: '170',
        firstName: 'J. REX',
        lastName: 'ANDERSON',
        badgeNumber: '170',
        rank: Rank.sergeantFirstClass,
        isSupervisor: true,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '103',
        firstName: 'J.D.',
        lastName: 'NEWPORT',
        badgeNumber: '103',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.day,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '112',
        firstName: 'A.J.',
        lastName: 'MILLS',
        badgeNumber: '112',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.day,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '141',
        firstName: 'G.B.',
        lastName: 'SHIPMAN',
        badgeNumber: '141',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.day,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '142',
        firstName: 'N.E.',
        lastName: 'BINGIEL',
        badgeNumber: '142',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.day,
        employmentStatus: EmploymentStatus.fullTime,
      ),

      // A-SPLIT 1200-2400 - 1 employee
      Employee(
        id: '113',
        firstName: 'P.E.',
        lastName: 'LIVELY',
        badgeNumber: '113',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.split1200,
        employmentStatus: EmploymentStatus.fullTime,
      ),

      // B-SPLIT 1200-2400 - 1 employee
      Employee(
        id: '153',
        firstName: 'J.T.',
        lastName: 'GREGG',
        badgeNumber: '153',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.split1200,
        employmentStatus: EmploymentStatus.fullTime,
      ),

      // A-SPLIT 1400-0200 - 1 employee
      Employee(
        id: '954',
        firstName: 'M.D.',
        lastName: 'RALSTON',
        badgeNumber: '954',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.split1400,
        employmentStatus: EmploymentStatus.fullTime,
      ),

      // B-SPLIT 1400-0200 - 1 employee
      Employee(
        id: '102',
        firstName: 'C.R.',
        lastName: 'MARTIN',
        badgeNumber: '102',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.split1400,
        employmentStatus: EmploymentStatus.fullTime,
      ),

      // A-NIGHT (1800-0600) - 5 employees
      Employee(
        id: '129',
        firstName: 'E.L.',
        lastName: 'KIRBY',
        badgeNumber: '129',
        rank: Rank.sergeantFirstClass,
        isSupervisor: true,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.day,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
          id: '120',
          firstName: 'J.P.',
          lastName: 'COFFEY',
          badgeNumber: '120',
          rank: Rank.deputy,
          isSupervisor: false,
          division: Division.patrol,
          shiftGroup: ShiftGroup.a,
          shiftType: Shift.night,
          employmentStatus: EmploymentStatus.fullTime),
      Employee(
        id: '106',
        firstName: 'B.D.',
        lastName: 'TURNER',
        badgeNumber: '106',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '109',
        firstName: 'Z.A.',
        lastName: 'JACKSON',
        badgeNumber: '109',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '177',
        firstName: 'C.J.',
        lastName: 'WALKER',
        badgeNumber: '177',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),

      // B-NIGHT (1800-0600) - 5 employees
      Employee(
        id: '161',
        firstName: 'S.M.',
        lastName: 'HENERY',
        badgeNumber: '161',
        rank: Rank.sergeantFirstClass,
        isSupervisor: true,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.day,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '150',
        firstName: 'M.D.',
        lastName: 'GALLMAN',
        badgeNumber: '150',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '162',
        firstName: 'R.L.',
        lastName: 'BURNS',
        badgeNumber: '162',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '181',
        firstName: 'C.L.',
        lastName: 'HILES',
        badgeNumber: '181',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '188',
        firstName: 'G.B.',
        lastName: 'PHILLIPS',
        badgeNumber: '188',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),

      // K-9
      Employee(
        id: '415',
        firstName: 'F.D.',
        lastName: 'PULLEN',
        badgeNumber: '415',
        rank: Rank.corporal,
        isSupervisor: true,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.fullTime,
      ),

      // SRO
      Employee(
        id: '013',
        firstName: 'J.T.',
        lastName: 'JENKINS JR',
        badgeNumber: '013',
        rank: Rank.captain,
        isSupervisor: true,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '023',
        firstName: 'G.B.',
        lastName: 'BRANNON (CHAMPS)',
        badgeNumber: '023',
        rank: Rank.lieutenant,
        isSupervisor: true,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '184',
        firstName: 'E.A.',
        lastName: 'OCHOA (CHAMPS/FTO)',
        badgeNumber: '184',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '193',
        firstName: 'J.A.',
        lastName: 'MORSE (FTO)',
        badgeNumber: '193',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.fullTime,
      ),

      // PART TIME
      Employee(
        id: '131',
        firstName: 'D.C.',
        lastName: 'BLALOCK',
        badgeNumber: '131',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.partTime,
      ),
      Employee(
        id: '136',
        firstName: 'C.L.',
        lastName: 'BALDWIN',
        badgeNumber: '136',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.partTime,
      ),
      Employee(
        id: '137',
        firstName: 'E.V.',
        lastName: 'SHELLEY',
        badgeNumber: '137',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.partTime,
      ),
      Employee(
        id: '143',
        firstName: 'J.R.',
        lastName: 'POWELL',
        badgeNumber: '143',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.partTime,
      ),
      Employee(
        id: '149',
        firstName: 'A.B.',
        lastName: 'SUTHERLAND',
        badgeNumber: '149',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.partTime,
      ),
      Employee(
        id: '123',
        firstName: 'C.A.',
        lastName: 'CHAMBERS',
        badgeNumber: '123',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.partTime,
      ),
      Employee(
        id: '195',
        firstName: 'C.A.',
        lastName: 'BLACK',
        badgeNumber: '195',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.partTime,
      ),
      Employee(
        id: '199',
        firstName: 'R.A.',
        lastName: 'PRAUSE',
        badgeNumber: '199',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.partTime,
      ),

      // Deputies on FTO
      Employee(
        id: '111',
        firstName: 'J.T.',
        lastName: 'COOPER',
        badgeNumber: '111',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '145',
        firstName: 'W.M.',
        lastName: 'KING',
        badgeNumber: '145',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.fullTime,
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
