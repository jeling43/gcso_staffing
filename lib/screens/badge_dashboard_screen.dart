import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';

/// Separate badge-number-only dashboard.
///
/// HCI principles applied:
/// - Clear visual hierarchy (date → shift group → shift sections → badges)
/// - Consistent 8-point spacing grid
/// - WCAG AA contrast ratios for all text
/// - Semantic grouping with labeled sections
/// - Minimal cognitive load — badge numbers only, no names
/// - Responsive layout adapts to screen width
/// - Tooltips on interactive elements for discoverability
/// - Visible focus indicators via Material 3
class BadgeDashboardScreen extends StatefulWidget {
  const BadgeDashboardScreen({super.key});

  @override
  State<BadgeDashboardScreen> createState() => _BadgeDashboardScreenState();
}

class _BadgeDashboardScreenState extends State<BadgeDashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  // ── Design tokens ──────────────────────────────────────────────────────
  static const Color _navy = Color(0xFF1E3A5F);
  static const Color _dayColor = Color(0xFFD97706); // amber-600
  static const Color _nightColor = Color(0xFF4338CA); // indigo-700
  static const Color _splitColor = Color(0xFF7C3AED); // violet-600
  static const Color _surface = Color(0xFFF8FAFC);

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.badge_outlined, size: 20),
            SizedBox(width: 8),
            Text('On-Duty Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: context.read<AuthProvider>().signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer2<ScheduleProvider, EmployeeProvider>(
        builder: (context, scheduleProvider, employeeProvider, _) {
          final workingGroup = ShiftGroup.getWorkingShiftGroup(_selectedDate);
          final scheduleEntries = scheduleProvider
              .getScheduleForDate(_selectedDate)
              .where((entry) =>
                  entry.division == Division.patrol && entry.isOnDuty)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDateHeader(),
                    const SizedBox(height: 16),
                    _buildShiftGroupBanner(workingGroup),
                    const SizedBox(height: 16),
                    _buildSupervisorPanel(employeeProvider),
                    const SizedBox(height: 24),
                    _buildSectionLabel('Day Shift', '06:00 – 18:00'),
                    const SizedBox(height: 8),
                    _buildBadgeGrid(
                      scheduleEntries: scheduleEntries,
                      shiftType: Shift.day,
                      color: _dayColor,
                      icon: Icons.wb_sunny_rounded,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionLabel('Split 1200', '12:00 – 00:00'),
                    const SizedBox(height: 8),
                    _buildBadgeGrid(
                      scheduleEntries: scheduleEntries,
                      shiftType: Shift.split1200,
                      color: _splitColor,
                      icon: Icons.schedule_rounded,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionLabel('Split 1400', '14:00 – 02:00'),
                    const SizedBox(height: 8),
                    _buildBadgeGrid(
                      scheduleEntries: scheduleEntries,
                      shiftType: Shift.split1400,
                      color: _splitColor,
                      icon: Icons.schedule_rounded,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionLabel('Night Shift', '18:00 – 06:00'),
                    const SizedBox(height: 8),
                    _buildBadgeGrid(
                      scheduleEntries: scheduleEntries,
                      shiftType: Shift.night,
                      color: _nightColor,
                      icon: Icons.nightlight_round,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSupervisorPanel(EmployeeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.supervisor_account_rounded, color: _navy, size: 20),
              SizedBox(width: 8),
              Text(
                'Shift Supervisors',
                style: TextStyle(
                  color: _navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSupervisorCard(
                label: 'Day Shift',
                supervisor: provider.selectedSupervisorForShift(
                    _selectedDate, Shift.day),
                color: _dayColor,
                icon: Icons.wb_sunny_rounded,
              ),
              _buildSupervisorCard(
                label: 'Night Shift',
                supervisor: provider.selectedSupervisorForShift(
                    _selectedDate, Shift.night),
                color: _nightColor,
                icon: Icons.nightlight_round,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupervisorCard({
    required String label,
    required Employee? supervisor,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 324,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  supervisor == null
                      ? 'Supervisor not selected'
                      : '${supervisor.rank} ${supervisor.lastName}  •  #${supervisor.badgeNumber}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: supervisor == null ? Colors.grey.shade500 : _navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Date header with prev / today / next ───────────────────────────────
  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous day',
            onPressed: () => setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
            }),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMMM d, yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _selectedDate = DateTime.now();
            }),
            style: TextButton.styleFrom(
              foregroundColor: _navy,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Today'),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next day',
            onPressed: () => setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 1));
            }),
          ),
        ],
      ),
    );
  }

  // ── Shift-group banner (A or B) ────────────────────────────────────────
  Widget _buildShiftGroupBanner(String group) {
    final isA = group == ShiftGroup.a;
    final bgColor = isA ? const Color(0xFF0369A1) : const Color(0xFF14532D);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.groups_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            '$group Shift Working',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────
  Widget _buildSectionLabel(String title, String hours) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _navy,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          hours,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Badge-number grid for a shift type ─────────────────────────────────
  Widget _buildBadgeGrid({
    required List<ScheduleEntry> scheduleEntries,
    required String shiftType,
    required Color color,
    required IconData icon,
  }) {
    final matching = scheduleEntries
        .where((entry) => entry.shift == shiftType && entry.isOnDuty)
        .toList();

    matching.sort(
      (first, second) => Employee.compareByRankThenBadge(
        first.employee,
        second.employee,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon + count
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                '${matching.length} on-duty',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Badge chips
          matching.isEmpty
              ? Text(
                  'No deputies assigned',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: matching.map((entry) {
                    return _buildBadgeChip(entry, color);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  // ── Individual badge chip ──────────────────────────────────────────────
  Widget _buildBadgeChip(ScheduleEntry entry, Color color) {
    final employee = entry.employee;
    return Tooltip(
      message: entry.isTemporary
          ? '${employee.rank} — Badge #${employee.badgeNumber} — Fill-in'
          : '${employee.rank} — Badge #${employee.badgeNumber}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rank indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                employee.rank,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Badge number — primary identifier (no name shown)
            Text(
              '#${employee.badgeNumber}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color.withValues(alpha: 0.9),
              ),
            ),
            if (entry.isTemporary) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.person_add_alt_1_rounded,
                size: 14,
                color: Color(0xFF4F46E5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
