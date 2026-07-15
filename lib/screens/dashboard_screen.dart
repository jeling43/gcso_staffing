import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';

/// Dashboard screen showing staffing overview by shift
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  // Track selected lieutenants for each shift
  final Map<String, Employee?> _selectedLieutenants = {
    Shift.day: null,
    Shift.night: null,
  };

  // Design tokens — HCI-compliant (WCAG AA contrast ratios)
  static const Color _primaryNavy = Color(0xFF0F172A);     // Slate-900: high contrast
  static const Color _accentGold = Color(0xFFB45309);      // Amber-700: AA on white
  static const Color _surfaceColor = Color(0xFFF8FAFC);    // Slate-50
  static const Color _onDutyGreen = Color(0xFF059669);     // Emerald-600
  static const Color _dayShiftColor = Color(0xFFD97706);   // Amber-600
  static const Color _nightShiftColor = Color(0xFF4338CA); // Indigo-700
  static const Color _splitShiftColor = Color(0xFF7C3AED); // Violet-600

  @override
  Widget build(BuildContext context) {
    final workingShiftGroup = ShiftGroup.getWorkingShiftGroup(_selectedDate);

    // HCI-compliant shift group colors — high contrast, consistent semantics
    final isAShift = workingShiftGroup == ShiftGroup.a;
    final gradientColors = isAShift
        ? [const Color(0xFF0369A1), const Color(0xFF0284C7)] // Sky-700→600
        : [const Color(0xFF0F172A), const Color(0xFF1E293B)]; // Slate-900→800
    final shadowColor = isAShift
        ? const Color(0xFF0369A1).withOpacity(0.25)
        : const Color(0xFF0F172A).withOpacity(0.25);
    final badgeColor =
        isAShift ? const Color(0xFF0369A1) : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: _surfaceColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Admin Dashboard'),
          ],
        ),
      ),
      body: Consumer2<ScheduleProvider, EmployeeProvider>(
        builder: (context, scheduleProvider, employeeProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Date Navigation Header
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavButton(
                          icon: Icons.chevron_left_rounded,
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate
                                  .subtract(const Duration(days: 1));
                            });
                          },
                          tooltip: 'Previous Day',
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                DateFormat('EEEE').format(_selectedDate),
                                style: TextStyle(
                                  color: _primaryNavy.withOpacity(0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMMM d, yyyy')
                                    .format(_selectedDate),
                                style: const TextStyle(
                                  color: _primaryNavy,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedDate = DateTime.now();
                                  });
                                },
                                icon: const Icon(Icons.today_rounded, size: 18),
                                label: const Text('Today'),
                                style: TextButton.styleFrom(
                                  foregroundColor: _primaryNavy,
                                  backgroundColor:
                                      _primaryNavy.withOpacity(0.08),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildNavButton(
                          icon: Icons.chevron_right_rounded,
                          onPressed: () {
                            setState(() {
                              _selectedDate =
                                  _selectedDate.add(const Duration(days: 1));
                            });
                          },
                          tooltip: 'Next Day',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Modern Working Shift Group Section
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 28.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isAShift
                              ? Icons.wb_sunny_rounded
                              : Icons.nightlight_round,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$workingShiftGroup SHIFT',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2,
                            ),
                          ),
                          const Text(
                            'CURRENTLY WORKING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Staff Breakdown by Shift Type - Modern Header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _primaryNavy,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Staff Breakdown',
                      style: TextStyle(
                        color: _primaryNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Day Shift
                _buildShiftTypeSection(
                  context,
                  scheduleProvider,
                  employeeProvider,
                  'Day Shift',
                  Shift.day,
                  Icons.wb_sunny_rounded,
                  _dayShiftColor,
                  badgeColor,
                ),
                const SizedBox(height: 16),

                // Night Shift
                _buildShiftTypeSection(
                  context,
                  scheduleProvider,
                  employeeProvider,
                  'Night Shift',
                  Shift.night,
                  Icons.nightlight_round,
                  _nightShiftColor,
                  badgeColor,
                ),
                const SizedBox(height: 16),

                // Split Shifts (Combined)
                _buildSplitShiftsSection(
                  context,
                  scheduleProvider,
                  badgeColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryNavy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _primaryNavy,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShiftTypeSection(
    BuildContext context,
    ScheduleProvider scheduleProvider,
    EmployeeProvider employeeProvider,
    String shiftName,
    String shiftType,
    IconData icon,
    Color color,
    Color badgeColor,
  ) {
    final scheduleEntries = scheduleProvider.getScheduleForDate(_selectedDate);
    final shiftEmployees = scheduleEntries
        .where((e) => e.shift == shiftType && e.isOnDuty)
        .toList();

    // Get ALL supervisors (LT only) from employee provider, not just those on this shift
    final supervisors = employeeProvider.employees
        .where((e) => e.rank == Rank.lieutenant && e.isSupervisor == true)
        .toList();

    // Sort by last name
    supervisors.sort((a, b) => a.lastName.compareTo(b.lastName));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        shiftName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_rounded, color: color, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${shiftEmployees.length}',
                            style: TextStyle(
                              color: color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (supervisors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildLieutenantDropdown(
                    context,
                    shiftType,
                    supervisors,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: shiftEmployees.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'No officers scheduled',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: shiftEmployees.map((entry) {
                      return _buildEmployeeCard(entry, badgeColor);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitShiftsSection(
    BuildContext context,
    ScheduleProvider scheduleProvider,
    Color badgeColor,
  ) {
    final scheduleEntries = scheduleProvider.getScheduleForDate(_selectedDate);
    final split1200Employees = scheduleEntries
        .where((e) => e.shift == Shift.split1200 && e.isOnDuty)
        .toList();
    final split1400Employees = scheduleEntries
        .where((e) => e.shift == Shift.split1400 && e.isOnDuty)
        .toList();
    final totalSplitEmployees =
        split1200Employees.length + split1400Employees.length;

    const Color splitColor = _splitShiftColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: splitColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [splitColor, splitColor.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.schedule_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Split Shifts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_rounded, color: splitColor, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '$totalSplitEmployees',
                        style: TextStyle(
                          color: splitColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (split1200Employees.isEmpty && split1400Employees.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'No officers scheduled',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                else ...[
                  if (split1200Employees.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: splitColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded,
                              color: splitColor, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Split-1200 (12:00-24:00)',
                            style: TextStyle(
                              color: splitColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: split1200Employees.map((entry) {
                        return _buildEmployeeCard(entry, badgeColor,
                            showShiftType: true);
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (split1400Employees.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: splitColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded,
                              color: splitColor, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Split-1400 (14:00-02:00)',
                            style: TextStyle(
                              color: splitColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: split1400Employees.map((entry) {
                        return _buildEmployeeCard(entry, badgeColor,
                            showShiftType: true);
                      }).toList(),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLieutenantDropdown(
    BuildContext context,
    String shiftType,
    List<Employee> supervisors,
  ) {
    final selectedLieutenant = _selectedLieutenants[shiftType];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _accentGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.supervisor_account_rounded,
                size: 18, color: _accentGold),
          ),
          const SizedBox(width: 10),
          const Text(
            'Supervisor:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButton<Employee>(
              value: selectedLieutenant,
              hint: Text(
                'Select Lieutenant',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              icon:
                  Icon(Icons.keyboard_arrow_down_rounded, color: _primaryNavy),
              items: supervisors.map((employee) {
                return DropdownMenuItem<Employee>(
                  value: employee,
                  child: _buildSupervisorText(employee),
                );
              }).toList(),
              onChanged: (Employee? newValue) {
                setState(() {
                  _selectedLieutenants[shiftType] = newValue;
                });
              },
              selectedItemBuilder: (BuildContext context) {
                return supervisors.map((employee) {
                  return _buildSupervisorText(employee);
                }).toList();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Get color for supervisor based on rank
  Color _getSupervisorColor(Employee employee) {
    // Only LT can be supervisors now
    return _accentGold; // Amber-700 for lieutenants (AA on white)
  }

  /// Build supervisor text widget with appropriate styling
  Widget _buildSupervisorText(Employee employee) {
    final textColor = _getSupervisorColor(employee);
    return Text(
      '${employee.rank} ${employee.lastName}',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  Widget _buildEmployeeCard(ScheduleEntry entry, Color badgeColor,
      {bool showShiftType = false}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 190),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [badgeColor, badgeColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    entry.employee.rank,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  '${entry.employee.rank} ${entry.employee.lastName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _primaryNavy,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.badge_outlined, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                '#${entry.employee.badgeNumber}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _onDutyGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _onDutyGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'On-Duty',
                      style: TextStyle(
                        color: _onDutyGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showShiftType) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _splitShiftColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                entry.shift,
                style: const TextStyle(
                  color: _splitShiftColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
