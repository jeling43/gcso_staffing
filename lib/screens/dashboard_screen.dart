import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import 'admin_login_screen.dart';

/// Dashboard screen showing staffing overview by shift
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  // Design tokens — HCI-compliant (WCAG AA contrast ratios)
  static const Color _primaryNavy =
      Color(0xFF0F172A); // Slate-900: high contrast
  static const Color _accentGold = Color(0xFFB45309); // Amber-700: AA on white
  static const Color _surfaceColor = Color(0xFFF8FAFC); // Slate-50
  static const Color _onDutyGreen = Color(0xFF059669); // Emerald-600
  static const Color _dayShiftColor = Color(0xFFD97706); // Amber-600
  static const Color _nightShiftColor = Color(0xFF4338CA); // Indigo-700
  static const Color _splitShiftColor = Color(0xFF7C3AED); // Violet-600

  @override
  Widget build(BuildContext context) {
    final workingShiftGroup = ShiftGroup.getWorkingShiftGroup(_selectedDate);

    // HCI-compliant shift group colors — high contrast, consistent semantics
    final isAShift = workingShiftGroup == ShiftGroup.a;
    final gradientColors = isAShift
        ? [const Color(0xFF0369A1), const Color(0xFF0284C7)] // Sky-700→600
        : [const Color(0xFF14532D), const Color(0xFF166534)]; // Green-900→800
    final shadowColor = isAShift
        ? const Color(0xFF0369A1).withOpacity(0.25)
        : const Color(0xFF14532D).withOpacity(0.25);
    final badgeColor =
        isAShift ? const Color(0xFF0369A1) : const Color(0xFF14532D);

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
            const Text(
              'Staffing Overview',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.isAuthenticated) {
                return IconButton(
                  tooltip: 'Sign out',
                  onPressed: authProvider.signOut,
                  icon: const Icon(Icons.logout_rounded),
                );
              }
              return TextButton.icon(
                onPressed: () => _openAdminLogin(context),
                icon: const Icon(Icons.lock_outline, color: Colors.white),
                label: const Text(
                  'Admin sign in',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer2<ScheduleProvider, EmployeeProvider>(
        builder: (context, scheduleProvider, employeeProvider, _) {
          final scheduleEntries =
              scheduleProvider.getScheduleForDate(_selectedDate);
          final onDutyCount =
              scheduleEntries.where((entry) => entry.isOnDuty).length;
          final absentCount =
              scheduleEntries.where((entry) => !entry.isOnDuty).length;
          final fillInCount = scheduleEntries
              .where((entry) => entry.isOnDuty && entry.isTemporary)
              .length;
          final dayCount = scheduleEntries
              .where((entry) => entry.isOnDuty && entry.shift == Shift.day)
              .length;
          final nightCount = scheduleEntries
              .where((entry) => entry.isOnDuty && entry.shift == Shift.night)
              .length;
          final splitCount = scheduleEntries
              .where((entry) =>
                  entry.isOnDuty &&
                  (entry.shift == Shift.split1200 ||
                      entry.shift == Shift.split1400))
              .length;

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
                        child: const Icon(
                          Icons.groups_rounded,
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
                const SizedBox(height: 20),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildSummaryCard(
                      label: 'On duty',
                      value: '$onDutyCount',
                      icon: Icons.check_circle_rounded,
                      color: _onDutyGreen,
                    ),
                    _buildSummaryCard(
                      label: 'Day shift',
                      value: '$dayCount',
                      icon: Icons.wb_sunny_rounded,
                      color: _dayShiftColor,
                    ),
                    _buildSummaryCard(
                      label: 'Night shift',
                      value: '$nightCount',
                      icon: Icons.nightlight_round,
                      color: _nightShiftColor,
                    ),
                    _buildSummaryCard(
                      label: 'Split shifts',
                      value: '$splitCount',
                      icon: Icons.schedule_rounded,
                      color: _splitShiftColor,
                    ),
                    _buildSummaryCard(
                      label: 'Absent',
                      value: '$absentCount',
                      icon: Icons.person_off_rounded,
                      color: const Color(0xFFDC2626),
                    ),
                    _buildSummaryCard(
                      label: 'Fill-ins',
                      value: '$fillInCount',
                      icon: Icons.person_add_alt_1_rounded,
                      color: const Color(0xFF4F46E5),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

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

                // Split Shifts (Combined)
                _buildSplitShiftsSection(
                  context,
                  scheduleProvider,
                  employeeProvider,
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 156,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: _primaryNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryNavy.withOpacity(0.65),
                    fontSize: 12,
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
    final canEdit = context.watch<AuthProvider>().isAuthenticated;
    final scheduleEntries = scheduleProvider.getScheduleForDate(_selectedDate);
    final shiftEmployees =
        scheduleEntries.where((e) => e.shift == shiftType).toList();
    final onDutyCount = shiftEmployees.where((e) => e.isOnDuty).length;

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
                    TextButton.icon(
                      onPressed: canEdit
                          ? () => _showAddFillInDialog(
                                context,
                                shiftType,
                                scheduleProvider,
                                employeeProvider,
                              )
                          : () => _openAdminLogin(context),
                      icon: Icon(
                        canEdit
                            ? Icons.person_add_alt_1_rounded
                            : Icons.lock_outline,
                        size: 18,
                      ),
                      label: Text(canEdit ? 'Add fill-in' : 'Sign in to edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                            '$onDutyCount',
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
                    employeeProvider,
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
                      return _buildEmployeeCard(
                        context,
                        entry,
                        badgeColor,
                        scheduleProvider,
                      );
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
    EmployeeProvider employeeProvider,
    Color badgeColor,
  ) {
    final canEdit = context.watch<AuthProvider>().isAuthenticated;
    final scheduleEntries = scheduleProvider.getScheduleForDate(_selectedDate);
    final split1200Employees =
        scheduleEntries.where((e) => e.shift == Shift.split1200).toList();
    final split1400Employees =
        scheduleEntries.where((e) => e.shift == Shift.split1400).toList();
    final totalSplitEmployees = [...split1200Employees, ...split1400Employees]
        .where((entry) => entry.isOnDuty)
        .length;

    final Color splitColor = _splitShiftColor;

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
                if (canEdit)
                  PopupMenuButton<String>(
                    tooltip: 'Add split-shift fill-in',
                    icon: const Icon(Icons.person_add_alt_1_rounded,
                        color: Colors.white),
                    onSelected: (shift) => _showAddFillInDialog(
                      context,
                      shift,
                      scheduleProvider,
                      employeeProvider,
                    ),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: Shift.split1200,
                        child: Text('Add to Split 1200'),
                      ),
                      PopupMenuItem(
                        value: Shift.split1400,
                        child: Text('Add to Split 1400'),
                      ),
                    ],
                  )
                else
                  IconButton(
                    tooltip: 'Sign in to edit',
                    onPressed: () => _openAdminLogin(context),
                    icon: const Icon(Icons.lock_outline, color: Colors.white),
                  ),
                const SizedBox(width: 8),
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
                        return _buildEmployeeCard(
                          context,
                          entry,
                          badgeColor,
                          scheduleProvider,
                          showShiftType: true,
                        );
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
                        return _buildEmployeeCard(
                          context,
                          entry,
                          badgeColor,
                          scheduleProvider,
                          showShiftType: true,
                        );
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
    EmployeeProvider employeeProvider,
  ) {
    final canEdit = context.watch<AuthProvider>().isAuthenticated;
    final selectedLieutenant =
        employeeProvider.selectedSupervisorForShift(_selectedDate, shiftType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 8,
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
          const Text(
            'Supervisor:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(
            width: 260,
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
              onChanged: canEdit
                  ? (Employee? newValue) {
                      employeeProvider.selectSupervisorForShift(
                        _selectedDate,
                        shiftType,
                        newValue,
                      );
                    }
                  : null,
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '${employee.rank} ${employee.lastName}',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  void _showAddFillInDialog(
    BuildContext context,
    String shiftType,
    ScheduleProvider scheduleProvider,
    EmployeeProvider employeeProvider,
  ) {
    final scheduledIds = scheduleProvider
        .getScheduleForDate(_selectedDate)
        .map((entry) => entry.employee.id)
        .toSet();
    final eligibleEmployees = employeeProvider.employees
        .where((employee) =>
            employee.division == Division.patrol &&
            !scheduledIds.contains(employee.id))
        .toList();
    Employee? selectedEmployee;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add fill-in to $shiftType shift'),
          content: SizedBox(
            width: 420,
            child: DropdownButtonFormField<Employee>(
              initialValue: selectedEmployee,
              decoration: const InputDecoration(labelText: 'Employee'),
              isExpanded: true,
              items: eligibleEmployees
                  .map(
                    (employee) => DropdownMenuItem(
                      value: employee,
                      child: Text(
                        '${employee.rank} ${employee.lastName} — #${employee.badgeNumber}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (employee) =>
                  setDialogState(() => selectedEmployee = employee),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedEmployee == null
                  ? null
                  : () {
                      if (!scheduleProvider.canAddToSplit(
                        shiftType,
                        _selectedDate,
                        Division.patrol,
                      )) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'That split shift already has an on-duty employee.',
                            ),
                          ),
                        );
                        return;
                      }

                      final employee = selectedEmployee!;
                      scheduleProvider.addScheduleEntry(
                        ScheduleEntry(
                          id: 'fillin_${employee.id}_${DateTime.now().microsecondsSinceEpoch}',
                          employee: employee,
                          division: Division.patrol,
                          date: DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                          ),
                          shift: shiftType,
                          isTemporary: true,
                        ),
                      );
                      Navigator.pop(dialogContext);
                    },
              child: const Text('Add fill-in'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeShiftDialog(
    BuildContext context,
    ScheduleEntry entry,
    ScheduleProvider scheduleProvider,
  ) {
    String selectedShift = entry.shift;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Change shift for #${entry.employee.badgeNumber}'),
          content: DropdownButtonFormField<String>(
            initialValue: selectedShift,
            decoration: const InputDecoration(labelText: 'Daily shift'),
            items: const [
              DropdownMenuItem(value: Shift.day, child: Text('Day')),
              DropdownMenuItem(
                  value: Shift.split1200, child: Text('Split 1200')),
              DropdownMenuItem(
                  value: Shift.split1400, child: Text('Split 1400')),
              DropdownMenuItem(value: Shift.night, child: Text('Night')),
            ],
            onChanged: (value) {
              if (value != null) {
                setDialogState(() => selectedShift = value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                scheduleProvider.updateScheduleEntry(
                  entry.copyWith(shift: selectedShift),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(
    BuildContext context,
    ScheduleEntry entry,
    Color badgeColor,
    ScheduleProvider scheduleProvider, {
    bool showShiftType = false,
  }) {
    final canEdit = context.watch<AuthProvider>().isAuthenticated;
    final isAbsent = !entry.isOnDuty;
    final statusColor = isAbsent
        ? const Color(0xFFDC2626)
        : entry.isTemporary
            ? const Color(0xFF4F46E5)
            : _onDutyGreen;
    final statusLabel = isAbsent
        ? 'Absent'
        : entry.isTemporary
            ? 'Fill-in'
            : 'On-Duty';

    return Container(
      constraints: const BoxConstraints(minWidth: 190),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAbsent ? const Color(0xFFFEF2F2) : Colors.white,
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isAbsent ? Colors.grey.shade600 : _primaryNavy,
                    letterSpacing: -0.2,
                    decoration: isAbsent ? TextDecoration.lineThrough : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (canEdit)
                PopupMenuButton<String>(
                  tooltip: 'Schedule actions',
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (action) {
                    if (action == 'absent') {
                      scheduleProvider.markEmployeeAbsent(entry.id, true);
                    } else if (action == 'present') {
                      scheduleProvider.markEmployeeAbsent(entry.id, false);
                    } else if (action == 'remove') {
                      scheduleProvider.removeScheduleEntry(entry.id);
                    } else if (action == 'shift') {
                      _showChangeShiftDialog(context, entry, scheduleProvider);
                    }
                  },
                  itemBuilder: (context) => [
                    if (entry.isTemporary)
                      const PopupMenuItem(
                        value: 'remove',
                        child: Text('Remove fill-in'),
                      )
                    else if (isAbsent)
                      const PopupMenuItem(
                        value: 'present',
                        child: Text('Mark present'),
                      )
                    else
                      const PopupMenuItem(
                        value: 'absent',
                        child: Text('Mark absent'),
                      ),
                    const PopupMenuItem(
                      value: 'shift',
                      child: Text('Change daily shift'),
                    ),
                  ],
                )
              else
                IconButton(
                  tooltip: 'Sign in to edit',
                  onPressed: () => _openAdminLogin(context),
                  icon: const Icon(Icons.lock_outline, size: 19),
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
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

  void _openAdminLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AdminLoginScreen(),
      ),
    );
  }
}
