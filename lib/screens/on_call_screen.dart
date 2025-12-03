import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';

/// Screen showing on-call assignments for all divisions
class OnCallScreen extends StatelessWidget {
  const OnCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('On-Call Assignments'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<OnCallProvider>(
        builder: (context, onCallProvider, _) {
          final activeAssignments = onCallProvider.getActiveOnCallAssignments();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current On-Call Staff',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Staff members currently on-call for each division',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),
                ...Division.values.map((division) => _buildDivisionOnCallCard(
                      context,
                      division,
                      onCallProvider.getOnCallForDivision(division),
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
            onPressed: () => _showAddOnCallDialog(context),
            label: const Text('Add On-Call'),
            icon: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildDivisionOnCallCard(
    BuildContext context,
    Division division,
    OnCallAssignment? assignment,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDivisionIcon(division),
                  color: _getDivisionColor(division),
                ),
                const SizedBox(width: 8),
                Text(
                  division.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            if (assignment != null) ...[
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getDivisionColor(division),
                  child: Text(
                    assignment.employee.firstName[0] +
                        assignment.employee.lastName[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(assignment.employee.fullName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Badge: ${assignment.employee.badgeNumber}'),
                    Text(
                      '${dateFormat.format(assignment.startDate)} - ${dateFormat.format(assignment.endDate)}',
                    ),
                    if (assignment.notes != null)
                      Text(
                        assignment.notes!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                trailing: const Icon(Icons.phone, color: Colors.green),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No on-call assignment for this period',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
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

  void _showAddOnCallDialog(BuildContext context) {
    final employeeProvider = context.read<EmployeeProvider>();
    final onCallProvider = context.read<OnCallProvider>();
    
    Employee? selectedEmployee;
    Division selectedDivision = Division.jail;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final availableEmployees = employeeProvider.getEmployeesByDivision(selectedDivision);
          
          return AlertDialog(
            title: const Text('Add On-Call Assignment'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      if (value != null) {
                        setState(() {
                          selectedDivision = value;
                          selectedEmployee = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Employee>(
                    value: selectedEmployee,
                    decoration: const InputDecoration(labelText: 'Employee'),
                    items: availableEmployees
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.fullName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedEmployee = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => startDate = date);
                            }
                          },
                          child: Text('Start: ${DateFormat('MMM d').format(startDate)}'),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: startDate,
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() => endDate = date);
                            }
                          },
                          child: Text('End: ${DateFormat('MMM d').format(endDate)}'),
                        ),
                      ),
                    ],
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
                onPressed: selectedEmployee == null
                    ? null
                    : () {
                        onCallProvider.addOnCallAssignment(OnCallAssignment(
                          id: 'oncall_${DateTime.now().millisecondsSinceEpoch}',
                          employee: selectedEmployee!,
                          division: selectedDivision,
                          startDate: startDate,
                          endDate: endDate,
                        ));
                        Navigator.pop(context);
                      },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}
