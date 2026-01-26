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
    'Day': null,
    'Night': null,
  };

  @override
  Widget build(BuildContext context) {
    final workingShiftGroup = ShiftGroup.getWorkingShiftGroup(_selectedDate);

    // Determine colors based on shift group
    final isAShift = workingShiftGroup == ShiftGroup.a;
    final gradientColors = isAShift
        ? [Colors.amber.shade700, Colors.amber.shade500]
        : [Colors.blue.shade700, Colors.blue.shade500];
    final shadowColor = isAShift
        ? Colors.amber.shade700.withOpacity(0.4)
        : Colors.blue.shade700.withOpacity(0.4);
    final badgeColor = isAShift ? Colors.amber.shade700 : Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GCSO Staffing Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Consumer<EmployeeProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    'Logged in as: ${provider.currentUser?.fullName ?? "Guest"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, scheduleProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Navigation Header
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
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
                                DateFormat('EEEE, MMMM d, yyyy')
                                    .format(_selectedDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedDate = DateTime.now();
                                  });
                                },
                                icon: const Icon(Icons.today, size: 16),
                                label: const Text('Today'),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
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
                const SizedBox(height: 16),

                // Prominent Working Shift Group Section
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAShift ? Icons.star : Icons.brightness_2,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$workingShiftGroup SHIFT WORKING',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Staff Breakdown by Shift Type
                Text(
                  'Staff Breakdown',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Day Shift
                _buildShiftTypeSection(
                  context,
                  scheduleProvider,
                  'Day Shift',
                  Shift.day,
                  Icons.wb_sunny,
                  Colors.orange,
                  badgeColor,
                ),
                const SizedBox(height: 12),

                // Night Shift
                _buildShiftTypeSection(
                  context,
                  scheduleProvider,
                  'Night Shift',
                  Shift.night,
                  Icons.nightlight_round,
                  Colors.indigo,
                  badgeColor,
                ),
                const SizedBox(height: 12),

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

  Widget _buildShiftTypeSection(
    BuildContext context,
    ScheduleProvider scheduleProvider,
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

    // Get supervisors (LT, SGT, SFC) for dropdown
    final supervisors = shiftEmployees
        .where((e) =>
            e.employee.rank == Rank.lieutenant ||
            e.employee.rank == Rank.sergeant ||
            e.employee.rank == Rank.sergeantFirstClass)
        .map((e) => e.employee)
        .toList();

    // Sort: SGT/SFC first, then LT
    supervisors.sort((a, b) {
      // SGT and SFC should come first
      final aIsSgtOrSfc = a.rank == Rank.sergeant || a.rank == Rank.sergeantFirstClass;
      final bIsSgtOrSfc = b.rank == Rank.sergeant || b.rank == Rank.sergeantFirstClass;
      
      if (aIsSgtOrSfc && !bIsSgtOrSfc) return -1;
      if (!aIsSgtOrSfc && bIsSgtOrSfc) return 1;
      
      // If both are same type, sort by last name
      return a.lastName.compareTo(b.lastName);
    });

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        shiftName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${shiftEmployees.length} officers',
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (supervisors.isNotEmpty) ...[
                  const SizedBox(height: 12),
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
            padding: const EdgeInsets.all(16.0),
            child: shiftEmployees.isEmpty
                ? const Text(
                    'No officers scheduled',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
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

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Split Shifts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalSplitEmployees officers',
                    style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (split1200Employees.isEmpty && split1400Employees.isEmpty)
                  const Text(
                    'No officers scheduled',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  )
                else ...[
                  if (split1200Employees.isNotEmpty) ...[
                    Text(
                      'Split-1200 (12:00-24:00)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: split1200Employees.map((entry) {
                        return _buildEmployeeCard(entry, badgeColor,
                            showShiftType: true);
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (split1400Employees.isNotEmpty) ...[
                    Text(
                      'Split-1400 (14:00-02:00)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.supervisor_account, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          const Text(
            'Shift Supervisor:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<Employee>(
              value: selectedLieutenant,
              hint: const Text(
                'Select Supervisor',
                style: TextStyle(fontSize: 14),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              items: supervisors.map((employee) {
                final textColor = _getSupervisorColor(employee);
                return DropdownMenuItem<Employee>(
                  value: employee,
                  child: Text(
                    '${employee.rank} ${employee.lastName}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (Employee? newValue) {
                setState(() {
                  _selectedLieutenants[shiftType] = newValue;
                });
              },
              selectedItemBuilder: (BuildContext context) {
                return supervisors.map((employee) {
                  final textColor = _getSupervisorColor(employee);
                  return Text(
                    '${employee.rank} ${employee.lastName}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
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
    if (employee.rank == Rank.lieutenant) {
      return Colors.amber.shade700; // Gold for lieutenants
    } else if (employee.rank == Rank.sergeant ||
        employee.rank == Rank.sergeantFirstClass) {
      return Colors.deepOrange.shade700; // Different color for SGT/SFC
    }
    return Colors.black87;
  }

  Widget _buildEmployeeCard(ScheduleEntry entry, Color badgeColor,
      {bool showShiftType = false}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: badgeColor.withOpacity(0.2),
                child: Text(
                  entry.employee.rank,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${entry.employee.rank} ${entry.employee.lastName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Badge: ${entry.employee.badgeNumber}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          if (showShiftType) ...[
            const SizedBox(height: 4),
            Text(
              entry.shift,
              style: TextStyle(
                color: Colors.purple.shade700,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
