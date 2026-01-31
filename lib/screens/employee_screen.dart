import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';

/// Screen for managing employees
class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  // Modern color palette
  static const Color _primaryNavy = Color(0xFF1E3A5F);
  static const Color _surfaceColor = Color(0xFFF8FAFC);

  /// Helper method to check if a rank can be a supervisor
  static bool _canBeSupervisor(String rank) {
    return rank == Rank.lieutenant;
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
          final employees = employeeProvider.employees;
          
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
                            colors: [_primaryNavy, _primaryNavy.withOpacity(0.8)],
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: _primaryNavy.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_rounded, color: _primaryNavy, size: 20),
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
                      'All Staff Members',
                      style: TextStyle(
                        color: _primaryNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Employee list with modern cards
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
                              Icon(Icons.person_off_rounded, size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'No employees assigned',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 12, color: Color(0xFFD4AF37)),
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
                    decoration: const InputDecoration(labelText: 'Badge Number'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRank,
                    decoration: const InputDecoration(labelText: 'Rank'),
                    items: const [
                      DropdownMenuItem(value: Rank.lieutenant, child: Text('Lieutenant (LT)')),
                      DropdownMenuItem(value: Rank.sergeantFirstClass, child: Text('Sergeant First Class (SFC)')),
                      DropdownMenuItem(value: Rank.sergeant, child: Text('Sergeant (SGT)')),
                      DropdownMenuItem(value: Rank.corporal, child: Text('Corporal (CPL)')),
                      DropdownMenuItem(value: Rank.deputy, child: Text('Deputy (DEP)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRank = value ?? Rank.deputy;
                        // Only LT can be supervisors
                        if (!EmployeeScreen._canBeSupervisor(selectedRank)) {
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
                      DropdownMenuItem(value: ShiftGroup.a, child: Text('A Shift')),
                      DropdownMenuItem(value: ShiftGroup.b, child: Text('B Shift')),
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
                      DropdownMenuItem(value: Shift.night, child: Text('Nights')),
                      DropdownMenuItem(value: Shift.split1200, child: Text('Split 1200')),
                      DropdownMenuItem(value: Shift.split1400, child: Text('Split 1400')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedShiftType = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedEmploymentStatus,
                    decoration: const InputDecoration(labelText: 'Employment Status'),
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
                    subtitle: Text('All employees are assigned to Patrol division'),
                    dense: true,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Supervisor'),
                    subtitle: !EmployeeScreen._canBeSupervisor(selectedRank)
                        ? const Text('Only LT can be supervisors',
                            style: TextStyle(fontSize: 12))
                        : null,
                    value: isSupervisor,
                    onChanged: EmployeeScreen._canBeSupervisor(selectedRank)
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
                    decoration: const InputDecoration(labelText: 'Badge Number'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRank,
                    decoration: const InputDecoration(labelText: 'Rank'),
                    items: const [
                      DropdownMenuItem(value: Rank.lieutenant, child: Text('Lieutenant (LT)')),
                      DropdownMenuItem(value: Rank.sergeantFirstClass, child: Text('Sergeant First Class (SFC)')),
                      DropdownMenuItem(value: Rank.sergeant, child: Text('Sergeant (SGT)')),
                      DropdownMenuItem(value: Rank.corporal, child: Text('Corporal (CPL)')),
                      DropdownMenuItem(value: Rank.deputy, child: Text('Deputy (DEP)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRank = value ?? Rank.deputy;
                        // Only LT can be supervisors
                        if (!EmployeeScreen._canBeSupervisor(selectedRank)) {
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
                      DropdownMenuItem(value: ShiftGroup.a, child: Text('A Shift')),
                      DropdownMenuItem(value: ShiftGroup.b, child: Text('B Shift')),
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
                      DropdownMenuItem(value: Shift.night, child: Text('Nights')),
                      DropdownMenuItem(value: Shift.split1200, child: Text('Split 1200')),
                      DropdownMenuItem(value: Shift.split1400, child: Text('Split 1400')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedShiftType = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedEmploymentStatus,
                    decoration: const InputDecoration(labelText: 'Employment Status'),
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
                    subtitle: !EmployeeScreen._canBeSupervisor(selectedRank)
                        ? const Text('Only LT can be supervisors',
                            style: TextStyle(fontSize: 12))
                        : null,
                    value: isSupervisor,
                    onChanged: EmployeeScreen._canBeSupervisor(selectedRank)
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
