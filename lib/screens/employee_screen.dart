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
                  'Patrol Division - Employee Directory',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'All Patrol staff members - ${employees.length} total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Patrol Division',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (employees.isEmpty)
                        const ListTile(
                          title: Text('No employees assigned'),
                        )
                      else
                        ...employees.map((employee) => Consumer<ScheduleProvider>(
                          builder: (context, scheduleProvider, _) {
                            // Find employee's shift from schedule
                            final schedule = scheduleProvider.scheduleEntries
                                .where((e) => e.employee.id == employee.id)
                                .toList();
                            final shift = schedule.isNotEmpty ? schedule.first.shift : 'Unassigned';
                            
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
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
                                '${employee.firstName} ${employee.lastName}${employee.isSupervisor ? " • Supervisor" : ""} • $shift Shift',
                              ),
                              trailing: employeeProvider.isCurrentUserSupervisor
                                  ? IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showEditEmployeeDialog(context, employee),
                                    )
                                  : null,
                            );
                          },
                        )),
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
            icon: const Icon(Icons.person_add),
          );
        },
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final employeeProvider = context.read<EmployeeProvider>();
    
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final badgeController = TextEditingController();
    bool isSupervisor = false;
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
                    DropdownMenuItem(value: Rank.corporal, child: Text('Corporal (CPL)')),
                    DropdownMenuItem(value: Rank.deputy, child: Text('Deputy (DEP)')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedRank = value ?? Rank.deputy);
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
                    division: Division.patrol,
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
                    DropdownMenuItem(value: Rank.corporal, child: Text('Corporal (CPL)')),
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
}
