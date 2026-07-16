import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Provider for managing employees across the application
class EmployeeProvider extends ChangeNotifier {
  final List<Employee> _employees = [];
  final Map<String, Employee?> _selectedSupervisors = {};

  List<Employee> get employees {
    final sortedEmployees = List<Employee>.of(_employees)
      ..sort(_compareEmployeesById);
    return List.unmodifiable(sortedEmployees);
  }

  static int _compareEmployeesById(Employee first, Employee second) {
    final firstId = int.tryParse(first.id);
    final secondId = int.tryParse(second.id);

    if (firstId != null && secondId != null) {
      return firstId.compareTo(secondId);
    }

    return first.id.compareTo(second.id);
  }

  // Everyone can modify schedule - no user authentication
  bool get isCurrentUserSupervisor => true;

  String _supervisorKey(DateTime date, String shiftType) {
    final dateKey =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$dateKey|$shiftType';
  }

  Employee? selectedSupervisorForShift(DateTime date, String shiftType) {
    return _selectedSupervisors[_supervisorKey(date, shiftType)];
  }

  void selectSupervisorForShift(
    DateTime date,
    String shiftType,
    Employee? employee,
  ) {
    _selectedSupervisors[_supervisorKey(date, shiftType)] = employee;
    notifyListeners();
  }

  EmployeeProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // GCSO Patrol Division Roster - Effective 12/23/2025
    // 42 total employees across all shifts
    _employees.addAll([
      // Employees ordered by numeric ID.
      Employee(
        id: '013',
        firstName: 'J.T.',
        lastName: 'JENKINS JR',
        badgeNumber: '013',
        rank: Rank.captain,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '014',
        firstName: 'C.L.',
        lastName: 'PHILLIPS (FTO/ UAV PILOT)',
        badgeNumber: '014',
        rank: Rank.lieutenant,
        isSupervisor: true,
        division: Division.patrol,
        //shiftGroup: ShiftGroup.a,
        //shiftType: Shift.day,
        employmentStatus: EmploymentStatus.fullTime,
      ),

      Employee(
        id: '018',
        firstName: 'T.R',
        lastName: 'JONES (FTO)',
        badgeNumber: '018',
        rank: Rank.lieutenant,
        isSupervisor: true,
        division: Division.patrol,
        //shiftGroup: ShiftGroup.b,
        //shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '023',
        firstName: 'G.B.',
        lastName: 'BRANNON (CHAMPS)',
        badgeNumber: '023',
        rank: Rank.lieutenant,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.fullTime,
      ),
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
        id: '106',
        firstName: 'B.D.',
        lastName: 'TURNER',
        badgeNumber: '106',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.day,
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
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.partTime,
      ),
      Employee(
        id: '111',
        firstName: 'J.T.',
        lastName: 'COOPER',
        badgeNumber: '111',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.night,
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
        id: '113',
        firstName: 'P.E.',
        lastName: 'LIVELY',
        badgeNumber: '113',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.day,
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
        id: '122',
        firstName: 'R.C.',
        lastName: 'GARCIA',
        badgeNumber: '122',
        rank: Rank.sergeantFirstClass,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
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
        id: '126',
        firstName: 'A.S.',
        lastName: 'Carnes',
        badgeNumber: '126',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '129',
        firstName: 'E.L.',
        lastName: 'KIRBY',
        badgeNumber: '129',
        rank: Rank.sergeantFirstClass,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.day,
        employmentStatus: EmploymentStatus.fullTime,
      ),
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
        id: '136',
        firstName: 'C.L.',
        lastName: 'BALDWIN',
        badgeNumber: '136',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
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
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.split1200,
        employmentStatus: EmploymentStatus.fullTime,
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
        id: '145',
        firstName: 'W.M.',
        lastName: 'KING',
        badgeNumber: '145',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
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
      Employee(
        id: '156',
        firstName: 'B.L',
        lastName: 'CRAIG',
        badgeNumber: '153',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '158',
        firstName: 'J.L.',
        lastName: 'HOLCOMBE',
        badgeNumber: '158',
        rank: Rank.sergeantFirstClass,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),
      Employee(
        id: '160',
        firstName: 'B.M.',
        lastName: 'SITTEN',
        badgeNumber: '160',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: null,
        shiftType: null,
        employmentStatus: EmploymentStatus.partTime,
      ),
      Employee(
        id: '161',
        firstName: 'S.M.',
        lastName: 'HENERY',
        badgeNumber: '161',
        rank: Rank.sergeantFirstClass,
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
        id: '170',
        firstName: 'J. REX',
        lastName: 'ANDERSON',
        badgeNumber: '170',
        rank: Rank.sergeantFirstClass,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.b,
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

      Employee(
        id: '954',
        firstName: 'M.D.',
        lastName: 'RALSTON',
        badgeNumber: '954',
        rank: Rank.deputy,
        isSupervisor: false,
        division: Division.patrol,
        shiftGroup: ShiftGroup.a,
        shiftType: Shift.night,
        employmentStatus: EmploymentStatus.fullTime,
      ),
    ]);
  }

  List<Employee> getEmployeesByDivision(Division division) {
    return employees.where((e) => e.division == division).toList();
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
