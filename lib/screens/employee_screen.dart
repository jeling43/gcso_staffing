import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';

/// Screen for managing employees
class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, employeeProvider, _) {
          final employees = employeeProvider.employees;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee Directory',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'All staff members by division',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),
                ...Division.values.map((division) => _buildDivisionSection(
                      context,
                      division,
                      employeeProvider.getEmployeesByDivision(division),
                      employeeProvider.isCurrentUserSupervisor,
                    )),
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
            icon: const Icon(Icons.person_add),
          );
        },
      ),
    );
  }

  Widget _buildDivisionSection(
    BuildContext context,
    Division division,
    List<Employee> employees,
    bool isSupervisor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        leading: Icon(
          _getDivisionIcon(division),
          color: _getDivisionColor(division),
        ),
        title: Text(division.displayName),
        subtitle: Text('${employees.length} employees'),
        initiallyExpanded: true,
        children: [
          if (employees.isEmpty)
            const ListTile(
              title: Text('No employees assigned'),
            )
          else
            ...employees.map((employee) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getDivisionColor(division),
                    child: Text(
                      employee.rank,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text('${employee.rank} ${employee.lastName} #${employee.badgeNumber}'),
                  subtitle: Text(
                    '${employee.firstName} ${employee.lastName}${employee.isSupervisor ? " • Supervisor" : ""}',
                  ),
                  trailing: isSupervisor
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditEmployeeDialog(context, employee);
                            } else if (value == 'reassign') {
                              _showReassignDialog(context, employee);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'reassign',
                              child: Text('Reassign Division'),
                            ),
                          ],
                        )
                      : null,
                )),
        ],
      ),
    );
  }

  IconData _getDivisionIcon(Division division) {
    switch (division) {
      case Division.jail:
        return Icons.security;
      case Division.patrol:
        return Icons.directions_car;
      case Division.courthouse:
        return Icons.account_balance;
    }
  }

  Color _getDivisionColor(Division division) {
    switch (division) {
      case Division.jail:
        return Colors.orange;
      case Division.patrol:
        return Colors.blue;
      case Division.courthouse:
        return Colors.purple;
    }
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final employeeProvider = context.read<EmployeeProvider>();
    
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final badgeController = TextEditingController();
    bool isSupervisor = false;
    Division? selectedDivision;
    String selectedRank = Rank.deputy;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Employee'),
          content: SizedBox(
            width: 400,
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
                    DropdownMenuItem(value: Rank.deputy, child: Text('Deputy (DEP)')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedRank = value ?? Rank.deputy);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Division>(
                  value: selectedDivision,
                  decoration: const InputDecoration(labelText: 'Division'),
                  items: Division.values
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d.displayName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedDivision = value);
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Supervisor'),
                  value: isSupervisor,
                  onChanged: (value) {
                    setState(() => isSupervisor = value ?? false);
                  },
                ),
              ],
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
                    division: selectedDivision,
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
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Employee'),
          content: SizedBox(
            width: 400,
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
                    DropdownMenuItem(value: Rank.deputy, child: Text('Deputy (DEP)')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedRank = value ?? Rank.deputy);
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Supervisor'),
                  value: isSupervisor,
                  onChanged: (value) {
                    setState(() => isSupervisor = value ?? false);
                  },
                ),
              ],
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

  void _showReassignDialog(BuildContext context, Employee employee) {
    final employeeProvider = context.read<EmployeeProvider>();
    Division? selectedDivision = employee.division;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Reassign ${employee.fullName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Note: Employees can only be assigned to one division at a time.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Division>(
                value: selectedDivision,
                decoration: const InputDecoration(labelText: 'New Division'),
                items: Division.values
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d.displayName),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedDivision = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedDivision == null
                  ? null
                  : () {
                      employeeProvider.assignToDivision(
                        employee.id,
                        selectedDivision!,
                      );
                      Navigator.pop(context);
                    },
              child: const Text('Reassign'),
            ),
          ],
        ),
      ),
    );
  }
}
