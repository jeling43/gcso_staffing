import 'division.dart';

/// Valid rank values for employees
class Rank {
  static const String captain = 'CAPT';
  static const String lieutenant = 'LT';
  static const String sergeantFirstClass = 'SFC';
  static const String sergeant = 'SGT';
  static const String corporal = 'CPL';
  static const String deputy = 'DEP';

  static const List<String> validRanks = [
    captain,
    lieutenant,
    sergeantFirstClass,
    sergeant,
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

  static const List<String> validTypes = [
    day,
    split1200,
    split1400,
    night,
  ];

  /// Get user-friendly display name for a shift
  static String getDisplayName(String shift) {
    switch (shift) {
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
    // Compare UTC calendar dates so daylight-saving transitions cannot turn a
    // calendar day into 23 or 25 hours and shift the rotation by one day.
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);
    final normalizedCycleStart = DateTime.utc(
      cycleStartDate.year,
      cycleStartDate.month,
      cycleStartDate.day,
    );
    final daysSinceStart =
        normalizedDate.difference(normalizedCycleStart).inDays;
    final cycleDay = ((daysSinceStart % 14) + 14) % 14;

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

  /// Standard command-order comparison used anywhere employees are displayed.
  static int compareByRankThenBadge(Employee first, Employee second) {
    final rankComparison =
        _rankPriority(first.rank).compareTo(_rankPriority(second.rank));
    if (rankComparison != 0) {
      return rankComparison;
    }

    final firstBadge = int.tryParse(first.badgeNumber);
    final secondBadge = int.tryParse(second.badgeNumber);
    if (firstBadge != null && secondBadge != null) {
      return firstBadge.compareTo(secondBadge);
    }
    return first.badgeNumber.compareTo(second.badgeNumber);
  }

  static int _rankPriority(String rank) {
    switch (rank) {
      case Rank.captain:
        return 0;
      case Rank.lieutenant:
        return 1;
      case Rank.sergeantFirstClass:
        return 2;
      case Rank.sergeant:
        return 3;
      case Rank.corporal:
        return 4;
      case Rank.deputy:
        return 5;
      default:
        return 6;
    }
  }

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
