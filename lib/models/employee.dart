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
  static const String split1200 = 'Split-1200';
  static const String split1400 = 'Split-1400';
  
  // Group A shifts
  static const String aDays = 'A-Days';
  static const String aSplit1200 = 'A-Split-1200';
  static const String aSplit1400 = 'A-Split-1400';
  static const String aNight = 'A-Night';
  
  // Group B shifts
  static const String bDays = 'B-Days';
  static const String bSplit1200 = 'B-Split-1200';
  static const String bSplit1400 = 'B-Split-1400';
  static const String bNight = 'B-Night';
  
  static const List<String> validShifts = [
    aDays, aSplit1200, aSplit1400, aNight,
    bDays, bSplit1200, bSplit1400, bNight
  ];
  
  /// Get user-friendly display name for a shift
  static String getDisplayName(String shift) {
    switch (shift) {
      case aDays:
        return 'Days Shift (A) - 06:00-18:00';
      case aSplit1200:
        return 'Split Shift 1200 (A) - 12:00-24:00';
      case aSplit1400:
        return 'Split Shift 1400 (A) - 14:00-02:00';
      case aNight:
        return 'Night Shift (A) - 18:00-06:00';
      case bDays:
        return 'Days Shift (B) - 06:00-18:00';
      case bSplit1200:
        return 'Split Shift 1200 (B) - 12:00-24:00';
      case bSplit1400:
        return 'Split Shift 1400 (B) - 14:00-02:00';
      case bNight:
        return 'Night Shift (B) - 18:00-06:00';
      // Fallback for generic shift types
      case day:
        return 'Days Shift - 06:00-18:00';
      case night:
        return 'Night Shift - 18:00-06:00';
      case split1200:
        return 'Split Shift 1200 - 12:00-24:00';
      case split1400:
        return 'Split Shift 1400 - 14:00-02:00';
      default:
        return shift;
    }
  }
}

/// Shift groups for swing schedule rotation
class ShiftGroup {
  static const String a = 'A';
  static const String b = 'B';
  
  static const List<String> validGroups = [a, b];
  
  /// A shift start date (January 5, 2026 - Sunday)
  /// A Shift pattern: 2 on, 2 off, 3 on, 3 off (10-day cycle)
  /// B Shift pattern: 2 off, 2 on, 3 off, 3 on (opposite of A)
  static final DateTime aShiftStartDate = DateTime(2026, 1, 5);
  
  /// Calculate which shift group is working on a given date
  /// Swing schedule: 2 on, 2 off, 3 on, 3 off (10-day cycle)
  /// Cycle Day 0-1: A Shift (2 days on)
  /// Cycle Day 2-3: B Shift (2 days on, A off)
  /// Cycle Day 4-6: A Shift (3 days on)
  /// Cycle Day 7-9: B Shift (3 days on, A off)
  static String getWorkingShiftGroup(DateTime date) {
    final daysSinceStart = date.difference(aShiftStartDate).inDays;
    final cycleDay = daysSinceStart % 10;
    
    if (cycleDay >= 0 && cycleDay <= 1) {
      return a; // Cycle days 0-1: A works 2 days
    } else if (cycleDay >= 2 && cycleDay <= 3) {
      return b; // Cycle days 2-3: B works 2 days (A off)
    } else if (cycleDay >= 4 && cycleDay <= 6) {
      return a; // Cycle days 4-6: A works 3 days
    } else {
      return b; // Cycle days 7-9: B works 3 days (A off)
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
  final String? shiftGroup; // "A" or "B" for swing schedule rotation
  final String? shiftType; // "Day", "Night", "Split-1200", "Split-1400"

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.badgeNumber,
    required this.rank,
    this.isSupervisor = false,
    this.division,
    this.shiftGroup,
    this.shiftType,
  }) : assert(Rank.validRanks.contains(rank), 'Invalid rank: $rank');

  String get fullName => '$firstName $lastName';
  
  /// Get the full shift assignment (e.g., "B Shift - Nights")
  String get shiftAssignment {
    if (shiftGroup == null || shiftType == null) {
      return 'Unassigned';
    }
    return '$shiftGroup Shift - $shiftType';
  }

  Employee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? badgeNumber,
    String? rank,
    bool? isSupervisor,
    Division? division,
    String? shiftGroup,
    String? shiftType,
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
      shiftType: shiftType ?? this.shiftType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
