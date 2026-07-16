import 'package:flutter_test/flutter_test.dart';
import 'package:gcso_staffing/models/employee.dart';

void main() {
  group('ShiftGroup calendar rotation', () {
    test('follows the configured 14-day anchor pattern', () {
      expect(
        ShiftGroup.getWorkingShiftGroup(DateTime(2026, 1, 2)),
        ShiftGroup.b,
      );
      expect(
        ShiftGroup.getWorkingShiftGroup(DateTime(2026, 1, 5)),
        ShiftGroup.a,
      );
      expect(
        ShiftGroup.getWorkingShiftGroup(DateTime(2026, 1, 7)),
        ShiftGroup.b,
      );
    });

    test('does not drift at the daylight-saving boundary', () {
      expect(
        ShiftGroup.getWorkingShiftGroup(DateTime(2026, 3, 8)),
        ShiftGroup.a,
      );
      expect(
        ShiftGroup.getWorkingShiftGroup(DateTime(2026, 3, 9)),
        ShiftGroup.b,
      );
      expect(
        ShiftGroup.getWorkingShiftGroup(DateTime(2026, 3, 10)),
        ShiftGroup.b,
      );
    });

    test('stays aligned later in the year', () {
      expect(
        ShiftGroup.getWorkingShiftGroup(DateTime(2026, 7, 26)),
        ShiftGroup.a,
      );
      expect(
        ShiftGroup.getWorkingShiftGroup(DateTime(2026, 7, 27)),
        ShiftGroup.b,
      );
    });
  });
}
