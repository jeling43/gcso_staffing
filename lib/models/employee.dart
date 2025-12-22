import 'division.dart';

/// Valid rank values for employees
class Rank {
  static const String lieutenant = 'LT';
  static const String sergeantFirstClass = 'SFC';
  static const String corporal = 'CPL';
  static const String deputy = 'DEP';
  
  static const List<String> validRanks = [lieutenant, sergeantFirstClass, corporal, deputy];
}

/// Valid shift names
class Shift {
  static const String day = 'Day';
  static const String night = 'Night';
  static const String split = 'Split';
  
  static const List<String> validShifts = [day, night, split];
}

/// Shift groups for swing schedule rotation
class ShiftGroup {
  static const String blue = 'Blue';
  static const String gold = 'Gold';
  
  static const List<String> validGroups = [blue, gold];
  
  /// Blue shift start date (January 2, 2026)
  static final DateTime blueShiftStartDate = DateTime(2026, 1, 2);
  
  /// Calculate which shift group is working on a given date
  /// Swing schedule: 3 on, 2 off, 2 on, 3 off (10-day cycle)
  static String getWorkingShiftGroup(DateTime date) {
    final daysSinceStart = date.difference(blueShiftStartDate).inDays;
    final cycleDay = daysSinceStart % 10;
    
    // Blue shift works: cycle days 0-2, 5-6 (3 on, 2 off, 2 on, 3 off)
    // Gold shift works: cycle days 3-4, 7-9 (opposite of Blue)
    if (cycleDay >= 0 && cycleDay <= 2) {
      return blue; // Cycle days 0-2 (first 3 days on)
    } else if (cycleDay >= 3 && cycleDay <= 4) {
      return gold; // Cycle days 3-4 (2 days off for Blue)
    } else if (cycleDay >= 5 && cycleDay <= 6) {
      return blue; // Cycle days 5-6 (2 days on)
    } else {
      return gold; // Cycle days 7-9 (3 days off for Blue)
    }
  }
  
  /// Check if a shift group is working on a given date
  static bool isShiftGroupWorking(String shiftGroup, DateTime date) {
    return getWorkingShiftGroup(date) == shiftGroup;
  }
}

/// Represents an employee in the Sheriff's Office
class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String badgeNumber;
  final String rank; // "LT", "SFC", "DEP"
  final bool isSupervisor;
  final Division? division; // Employees can only be assigned to one division
  final String? shiftGroup; // "Blue" or "Gold" for swing schedule rotation

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.badgeNumber,
    required this.rank,
    this.isSupervisor = false,
    this.division,
    this.shiftGroup,
  }) : assert(Rank.validRanks.contains(rank), 'Invalid rank: $rank');

  String get fullName => '$firstName $lastName';

  Employee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? badgeNumber,
    String? rank,
    bool? isSupervisor,
    Division? division,
    String? shiftGroup,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      rank: rank ?? this.rank,
      isSupervisor: isSupervisor ?? this.isSupervisor,
      division: division ?? this.division,
      shiftGroup: shiftGroup ?? this.shiftGroup,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
