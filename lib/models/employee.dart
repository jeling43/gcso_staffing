import 'division.dart';

/// Valid rank values for employees
class Rank {
  static const String lieutenant = 'LT';
  static const String sergeantFirstClass = 'SFC';
  static const String corporal = 'CPL';
  static const String deputy = 'DEP';

  static const List<String> validRanks = [
    lieutenant,
    sergeantFirstClass,
    corporal,
    deputy
  ];
}

/// Valid employment status values for employees
class EmploymentStatus {
  static const String fullTime = 'Full-time';
  static const String partTime = 'Part-time';
  static const String all = 'All'; // For filter UI

  static const List<String> validStatuses = [
    fullTime,
    partTime,
  ];
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
    aDays,
    aSplit1200,
    aSplit1400,
    aNight,
    bDays,
    bSplit1200,
    bSplit1400,
    bNight
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

  /// Shift cycle start date (January 2, 2026 - B Shift works first weekend)
  /// 14-day swing schedule cycle - shifts alternate weekends (Fri-Sat-Sun)
  /// Pattern: Weekend shift works Fri-Sat-Sun (3 days), then weekdays alternate 2 on, 2 off
  static final DateTime cycleStartDate = DateTime(2026, 1, 2);

  /// Calculate which shift group is working on a given date
  /// 14-day swing schedule cycle:
  /// - Days 0-2 (Fri-Sun): B works weekend
  /// - Days 3-4 (Mon-Tue): A works 2 days
  /// - Days 5-6 (Wed-Thu): B works 2 days
  /// - Days 7-9 (Fri-Sun): A works weekend
  /// - Days 10-11 (Mon-Tue): B works 2 days
  /// - Days 12-13 (Wed-Thu): A works 2 days
  static String getWorkingShiftGroup(DateTime date) {
    final daysSinceStart = date.difference(cycleStartDate).inDays;
    final cycleDay = daysSinceStart % 14;

    // B Shift working days:  0-2 (weekend), 5-6 (weekdays), 10-11 (weekdays)
    // A Shift working days: 3-4 (weekdays), 7-9 (weekend), 12-13 (weekdays)
    if ((cycleDay >= 0 && cycleDay <= 2) || // B weekend (Fri-Sat-Sun)
        (cycleDay >= 5 && cycleDay <= 6) || // B weekdays (Wed-Thu)
        (cycleDay >= 10 && cycleDay <= 11)) {
      // B weekdays (Mon-Tue)
      return b;
    } else {
      return a;
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
  final String? employmentStatus; // "Full-time", "Part-time", or null

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
    this.employmentStatus,
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
    String? employmentStatus,
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
      employmentStatus: employmentStatus ?? this.employmentStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
