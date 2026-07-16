import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';

/// Screen for managing employees
class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _shiftGroupFilter;
  String? _shiftTypeFilter;
  String? _employmentFilter;
  bool _groupByShift = true;

  // Modern color palette
  static const Color _primaryNavy = Color(0xFF1E3A5F);
  static const Color _surfaceColor = Color(0xFFF8FAFC);

  /// Helper method to check if a rank can be a supervisor
  static bool _canBeSupervisor(String rank) {
    return rank == Rank.lieutenant;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.people_rounded, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Employee Directory'),
          ],
        ),
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, employeeProvider, _) {
          final query = _searchController.text.trim().toLowerCase();
          final employees = employeeProvider.employees.where((employee) {
            final matchesSearch = query.isEmpty ||
                employee.fullName.toLowerCase().contains(query) ||
                employee.badgeNumber.toLowerCase().contains(query);
            final matchesGroup = _shiftGroupFilter == null ||
                employee.shiftGroup == _shiftGroupFilter;
            final matchesShift = _shiftTypeFilter == null ||
                employee.shiftType == _shiftTypeFilter;
            final matchesEmployment = _employmentFilter == null ||
                employee.employmentStatus == _employmentFilter;
            return matchesSearch &&
                matchesGroup &&
                matchesShift &&
                matchesEmployment;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern header section
                Container(
                  padding: const EdgeInsets.all(24),
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _primaryNavy,
                              _primaryNavy.withOpacity(0.8)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.directions_car_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Patrol Division',
                              style: TextStyle(
                                color: _primaryNavy,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Employee Directory',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: _primaryNavy.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_rounded,
                                color: _primaryNavy, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${employees.length} Total',
                              style: TextStyle(
                                color: _primaryNavy,
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
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Color(0xFF92400E), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Roster edits are temporary and reset when the application reloads.',
                          style: TextStyle(
                            color: Color(0xFF78350F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildFilters(employeeProvider.employees.length),
                const SizedBox(height: 24),

                // Section header
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
                      _groupByShift
                          ? 'Shift Assignments (${employees.length})'
                          : 'Staff Members (${employees.length})',
                      style: TextStyle(
                        color: _primaryNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: true,
                          icon: Icon(Icons.view_week_rounded),
                          label: Text('By shift'),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          icon: Icon(Icons.format_list_bulleted_rounded),
                          label: Text('All employees'),
                        ),
                      ],
                      selected: {_groupByShift},
                      onSelectionChanged: (selection) {
                        setState(() => _groupByShift = selection.first);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Employee list with modern cards
                if (_groupByShift)
                  _buildShiftGroupedRoster(
                    context,
                    employees,
                    employeeProvider,
                  )
                else
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
                    child: Column(
                      children: [
                        if (employees.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(Icons.person_off_rounded,
                                    size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text(
                                  'No employees assigned',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        else
                          ...employees.asMap().entries.map((entry) {
                            final index = entry.key;
                            final employee = entry.value;
                            final isLast = index == employees.length - 1;

                            return _buildEmployeeListItem(
                              context,
                              employee,
                              employeeProvider,
                              isLast: isLast,
                            );
                          }),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<EmployeeProvider>(
        builder: (context, employeeProvider, _) {
          if (!employeeProvider.isCurrentUserSupervisor) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _showAddEmployeeDialog(context),
            label: const Text('Add Employee'),
            icon: const Icon(Icons.person_add_rounded),
            backgroundColor: _primaryNavy,
            foregroundColor: Colors.white,
          );
        },
      ),
    );
  }

  Widget _buildFilters(int totalEmployees) {
    final hasActiveFilters = _searchController.text.isNotEmpty ||
        _shiftGroupFilter != null ||
        _shiftTypeFilter != null ||
        _employmentFilter != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list_rounded, color: _primaryNavy),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Find and filter staff',
                  style: TextStyle(
                    color: _primaryNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _shiftGroupFilter = null;
                      _shiftTypeFilter = null;
                      _employmentFilter = null;
                    });
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Search by name or badge number',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFilterDropdown(
                label: 'Shift group',
                value: _shiftGroupFilter,
                items: const {
                  ShiftGroup.a: 'A Shift',
                  ShiftGroup.b: 'B Shift',
                },
                onChanged: (value) => setState(() => _shiftGroupFilter = value),
              ),
              _buildFilterDropdown(
                label: 'Shift type',
                value: _shiftTypeFilter,
                items: const {
                  Shift.day: 'Day',
                  Shift.night: 'Night',
                  Shift.split1200: 'Split 1200',
                  Shift.split1400: 'Split 1400',
                },
                onChanged: (value) => setState(() => _shiftTypeFilter = value),
              ),
              _buildFilterDropdown(
                label: 'Employment',
                value: _employmentFilter,
                items: const {
                  EmploymentStatus.fullTime: 'Full-time',
                  EmploymentStatus.partTime: 'Part-time',
                },
                onChanged: (value) => setState(() => _employmentFilter = value),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$totalEmployees employees in the roster',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 190,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('All'),
          ),
          ...items.entries.map(
            (entry) => DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildShiftGroupedRoster(
    BuildContext context,
    List<Employee> employees,
    EmployeeProvider employeeProvider,
  ) {
    if (employees.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.person_off_rounded,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No employees match these filters',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    final unassigned = employees
        .where((employee) =>
            employee.shiftGroup == null || employee.shiftType == null)
        .toList()
      ..sort(Employee.compareByRankThenBadge);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShiftGroupSection(
          context,
          ShiftGroup.a,
          employees,
          employeeProvider,
        ),
        const SizedBox(height: 20),
        _buildShiftGroupSection(
          context,
          ShiftGroup.b,
          employees,
          employeeProvider,
        ),
        if (unassigned.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildUnassignedSection(context, unassigned, employeeProvider),
        ],
      ],
    );
  }

  Widget _buildShiftGroupSection(
    BuildContext context,
    String shiftGroup,
    List<Employee> employees,
    EmployeeProvider employeeProvider,
  ) {
    final groupEmployees = employees
        .where((employee) => employee.shiftGroup == shiftGroup)
        .toList()
      ..sort(Employee.compareByRankThenBadge);
    const shiftTypes = [
      Shift.day,
      Shift.split1200,
      Shift.split1400,
      Shift.night,
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _primaryNavy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  shiftGroup,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$shiftGroup Shift',
                      style: const TextStyle(
                        color: _primaryNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${groupEmployees.length} assigned employees',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth >= 760
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: shiftTypes.map((shiftType) {
                  final shiftEmployees = groupEmployees
                      .where((employee) => employee.shiftType == shiftType)
                      .toList();
                  return SizedBox(
                    width: cardWidth,
                    child: _buildShiftRosterCard(
                      context,
                      shiftType,
                      shiftEmployees,
                      employeeProvider,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShiftRosterCard(
    BuildContext context,
    String shiftType,
    List<Employee> employees,
    EmployeeProvider employeeProvider,
  ) {
    final color = _getShiftColor(shiftType);

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                Icon(_getShiftIcon(shiftType), color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getShiftLabel(shiftType),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${employees.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (employees.isEmpty)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                'No employees assigned',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            )
          else
            ...employees.asMap().entries.map((entry) {
              final employee = entry.value;
              return Column(
                children: [
                  _buildCompactEmployeeRow(
                    context,
                    employee,
                    employeeProvider,
                  ),
                  if (entry.key != employees.length - 1)
                    Divider(
                      height: 1,
                      indent: 14,
                      endIndent: 14,
                      color: color.withOpacity(0.12),
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCompactEmployeeRow(
    BuildContext context,
    Employee employee,
    EmployeeProvider employeeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getRankColor(employee.rank),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              employee.rank,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${employee.rank} ${employee.lastName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${employee.fullName}  •  #${employee.badgeNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
          if (employee.isSupervisor)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Tooltip(
                message: 'Supervisor',
                child: Icon(Icons.star_rounded,
                    color: Color(0xFFD4AF37), size: 18),
              ),
            ),
          if (employeeProvider.isCurrentUserSupervisor)
            IconButton(
              tooltip: 'Edit ${employee.fullName}',
              onPressed: () => _showEditEmployeeDialog(context, employee),
              icon: const Icon(Icons.edit_rounded, size: 18),
              color: _primaryNavy,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Widget _buildUnassignedSection(
    BuildContext context,
    List<Employee> employees,
    EmployeeProvider employeeProvider,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFF92400E)),
              const SizedBox(width: 8),
              Text(
                'Unassigned (${employees.length})',
                style: const TextStyle(
                  color: Color(0xFF78350F),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...employees.map(
            (employee) => _buildCompactEmployeeRow(
              context,
              employee,
              employeeProvider,
            ),
          ),
        ],
      ),
    );
  }

  String _getShiftLabel(String shiftType) {
    switch (shiftType) {
      case Shift.day:
        return 'Day • 06:00–18:00';
      case Shift.split1200:
        return 'Split 1200 • 12:00–00:00';
      case Shift.split1400:
        return 'Split 1400 • 14:00–02:00';
      case Shift.night:
        return 'Night • 18:00–06:00';
      default:
        return shiftType;
    }
  }

  IconData _getShiftIcon(String shiftType) {
    switch (shiftType) {
      case Shift.day:
        return Icons.wb_sunny_rounded;
      case Shift.night:
        return Icons.nightlight_round;
      default:
        return Icons.schedule_rounded;
    }
  }

  Color _getShiftColor(String shiftType) {
    switch (shiftType) {
      case Shift.day:
        return const Color(0xFFB45309);
      case Shift.split1200:
        return const Color(0xFF475569);
      case Shift.split1400:
        return const Color(0xFF334155);
      case Shift.night:
        return const Color(0xFF1E3A5F);
      default:
        return _primaryNavy;
    }
  }

  Widget _buildEmployeeListItem(
    BuildContext context,
    Employee employee,
    EmployeeProvider employeeProvider, {
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getRankColor(employee.rank),
                      _getRankColor(employee.rank).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    employee.rank,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${employee.rank} ${employee.lastName}',
                          style: TextStyle(
                            color: _primaryNavy,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _primaryNavy.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${employee.badgeNumber}',
                            style: TextStyle(
                              color: _primaryNavy,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (employee.isSupervisor) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 12, color: Color(0xFFD4AF37)),
                                SizedBox(width: 4),
                                Text(
                                  'Supervisor',
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${employee.firstName} ${employee.lastName}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employee.shiftAssignment,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (employeeProvider.isCurrentUserSupervisor)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showEditEmployeeDialog(context, employee),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _primaryNavy.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: _primaryNavy,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 80,
            endIndent: 16,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case Rank.captain:
        return const Color(0xFFD4AF37); // Gold
      case Rank.lieutenant:
        return const Color(0xFFD4AF37); // Gold
      case Rank.sergeantFirstClass:
        return const Color(0xFF4F46E5); // Indigo
      case Rank.sergeant:
        return const Color(0xFF4F46E5); // Indigo
      case Rank.corporal:
        return const Color(0xFF0EA5E9); // Sky blue
      default:
        return _primaryNavy;
    }
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final employeeProvider = context.read<EmployeeProvider>();

    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final badgeController = TextEditingController();
    bool isSupervisor = false;
    String selectedRank = Rank.deputy;
    String? selectedShiftGroup;
    String? selectedShiftType;
    String? selectedEmploymentStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Employee'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: badgeController,
                    decoration:
                        const InputDecoration(labelText: 'Badge Number'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRank,
                    decoration: const InputDecoration(labelText: 'Rank'),
                    items: const [
                      DropdownMenuItem(
                          value: Rank.lieutenant,
                          child: Text('Lieutenant (LT)')),
                      DropdownMenuItem(
                          value: Rank.sergeantFirstClass,
                          child: Text('Sergeant First Class (SFC)')),
                      DropdownMenuItem(
                          value: Rank.sergeant, child: Text('Sergeant (SGT)')),
                      DropdownMenuItem(
                          value: Rank.corporal, child: Text('Corporal (CPL)')),
                      DropdownMenuItem(
                          value: Rank.deputy, child: Text('Deputy (DEP)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRank = value ?? Rank.deputy;
                        // Only LT can be supervisors
                        if (!_canBeSupervisor(selectedRank)) {
                          isSupervisor = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedShiftGroup,
                    decoration: const InputDecoration(labelText: 'Shift Group'),
                    items: const [
                      DropdownMenuItem(
                          value: ShiftGroup.a, child: Text('A Shift')),
                      DropdownMenuItem(
                          value: ShiftGroup.b, child: Text('B Shift')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedShiftGroup = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedShiftType,
                    decoration: const InputDecoration(labelText: 'Shift Time'),
                    items: const [
                      DropdownMenuItem(value: Shift.day, child: Text('Days')),
                      DropdownMenuItem(
                          value: Shift.night, child: Text('Nights')),
                      DropdownMenuItem(
                          value: Shift.split1200, child: Text('Split 1200')),
                      DropdownMenuItem(
                          value: Shift.split1400, child: Text('Split 1400')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedShiftType = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedEmploymentStatus,
                    decoration:
                        const InputDecoration(labelText: 'Employment Status'),
                    items: EmploymentStatus.validStatuses
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedEmploymentStatus = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.directions_car),
                    title: Text('Division: Patrol'),
                    subtitle:
                        Text('All employees are assigned to Patrol division'),
                    dense: true,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Supervisor'),
                    subtitle: !_canBeSupervisor(selectedRank)
                        ? const Text('Only LT can be supervisors',
                            style: TextStyle(fontSize: 12))
                        : null,
                    value: isSupervisor,
                    onChanged: _canBeSupervisor(selectedRank)
                        ? (value) {
                            setState(() => isSupervisor = value ?? false);
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (firstNameController.text.isNotEmpty &&
                    lastNameController.text.isNotEmpty &&
                    badgeController.text.isNotEmpty) {
                  employeeProvider.addEmployee(Employee(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    badgeNumber: badgeController.text,
                    rank: selectedRank,
                    isSupervisor: isSupervisor,
                    division: Division.patrol,
                    shiftGroup: selectedShiftGroup,
                    shiftType: selectedShiftType,
                    employmentStatus: selectedEmploymentStatus,
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context, Employee employee) {
    final employeeProvider = context.read<EmployeeProvider>();

    final firstNameController = TextEditingController(text: employee.firstName);
    final lastNameController = TextEditingController(text: employee.lastName);
    final badgeController = TextEditingController(text: employee.badgeNumber);
    bool isSupervisor = employee.isSupervisor;
    String selectedRank = employee.rank;
    String? selectedShiftGroup = employee.shiftGroup;
    String? selectedShiftType = employee.shiftType;
    String? selectedEmploymentStatus = employee.employmentStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Employee'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: badgeController,
                    decoration:
                        const InputDecoration(labelText: 'Badge Number'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRank,
                    decoration: const InputDecoration(labelText: 'Rank'),
                    items: const [
                      DropdownMenuItem(
                          value: Rank.lieutenant,
                          child: Text('Lieutenant (LT)')),
                      DropdownMenuItem(
                          value: Rank.sergeantFirstClass,
                          child: Text('Sergeant First Class (SFC)')),
                      DropdownMenuItem(
                          value: Rank.sergeant, child: Text('Sergeant (SGT)')),
                      DropdownMenuItem(
                          value: Rank.corporal, child: Text('Corporal (CPL)')),
                      DropdownMenuItem(
                          value: Rank.deputy, child: Text('Deputy (DEP)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRank = value ?? Rank.deputy;
                        // Only LT can be supervisors
                        if (!_canBeSupervisor(selectedRank)) {
                          isSupervisor = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedShiftGroup,
                    decoration: const InputDecoration(labelText: 'Shift Group'),
                    items: const [
                      DropdownMenuItem(
                          value: ShiftGroup.a, child: Text('A Shift')),
                      DropdownMenuItem(
                          value: ShiftGroup.b, child: Text('B Shift')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedShiftGroup = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedShiftType,
                    decoration: const InputDecoration(labelText: 'Shift Time'),
                    items: const [
                      DropdownMenuItem(value: Shift.day, child: Text('Days')),
                      DropdownMenuItem(
                          value: Shift.night, child: Text('Nights')),
                      DropdownMenuItem(
                          value: Shift.split1200, child: Text('Split 1200')),
                      DropdownMenuItem(
                          value: Shift.split1400, child: Text('Split 1400')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedShiftType = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedEmploymentStatus,
                    decoration:
                        const InputDecoration(labelText: 'Employment Status'),
                    items: EmploymentStatus.validStatuses
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedEmploymentStatus = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Supervisor'),
                    subtitle: !_canBeSupervisor(selectedRank)
                        ? const Text('Only LT can be supervisors',
                            style: TextStyle(fontSize: 12))
                        : null,
                    value: isSupervisor,
                    onChanged: _canBeSupervisor(selectedRank)
                        ? (value) {
                            setState(() => isSupervisor = value ?? false);
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (firstNameController.text.isNotEmpty &&
                    lastNameController.text.isNotEmpty &&
                    badgeController.text.isNotEmpty) {
                  employeeProvider.updateEmployee(employee.copyWith(
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    badgeNumber: badgeController.text,
                    rank: selectedRank,
                    isSupervisor: isSupervisor,
                    shiftGroup: selectedShiftGroup,
                    shiftType: selectedShiftType,
                    employmentStatus: selectedEmploymentStatus,
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
