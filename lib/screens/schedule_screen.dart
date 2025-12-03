import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';

/// Screen for managing schedules (supervisor only)
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  Division? _selectedDivision;

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();
    final isSupervisor = employeeProvider.isCurrentUserSupervisor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Select Date',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedule',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                            });
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedDate = DateTime.now();
                            });
                          },
                          child: const Text('Today'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate.add(const Duration(days: 1));
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  children: [
                    FilterChip(
                      label: const Text('All Divisions'),
                      selected: _selectedDivision == null,
                      onSelected: (selected) {
                        setState(() => _selectedDivision = null);
                      },
                    ),
                    ...Division.values.map((division) => FilterChip(
                          label: Text(division.displayName),
                          selected: _selectedDivision == division,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDivision = selected ? division : null;
                            });
                          },
                        )),
                  ],
                ),
                const SizedBox(height: 24),
                if (!isSupervisor)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber),
                        SizedBox(width: 8),
                        Text('Only supervisors can modify the schedule.'),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                ..._buildScheduleCards(context, scheduleProvider, isSupervisor),
              ],
            ),
          );
        },
      ),
      floatingActionButton: isSupervisor
          ? FloatingActionButton.extended(
              onPressed: () => _showAddScheduleDialog(context),
              label: const Text('Add Schedule'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  List<Widget> _buildScheduleCards(
    BuildContext context,
    ScheduleProvider scheduleProvider,
    bool isSupervisor,
  ) {
    final divisions = _selectedDivision != null
        ? [_selectedDivision!]
        : Division.values;

    return divisions.map((division) {
      final entries = scheduleProvider.getScheduleByDivision(
        division,
        date: _selectedDate,
      );

      return Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _getDivisionColor(division).withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
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
                  const Spacer(),
                  Text(
                    '${entries.where((e) => e.isOnDuty).length} on duty',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No schedule entries for this date'),
              )
            else
              ...entries.map((entry) => _buildScheduleEntryTile(
                    context,
                    entry,
                    isSupervisor,
                    scheduleProvider,
                  )),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildScheduleEntryTile(
    BuildContext context,
    ScheduleEntry entry,
    bool isSupervisor,
    ScheduleProvider scheduleProvider,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: entry.isOnDuty ? Colors.green : Colors.grey,
        child: Text(
          entry.employee.firstName[0] + entry.employee.lastName[0],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(entry.employee.fullName),
      subtitle: Text('${entry.shift} Shift • Badge: ${entry.employee.badgeNumber}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(entry.isOnDuty ? 'On Duty' : 'Off Duty'),
            backgroundColor: entry.isOnDuty ? Colors.green[100] : Colors.grey[300],
          ),
          if (isSupervisor) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'toggle') {
                  scheduleProvider.toggleOnDutyStatus(entry.id);
                } else if (value == 'edit') {
                  _showEditScheduleDialog(context, entry);
                } else if (value == 'remove') {
                  scheduleProvider.removeScheduleEntry(entry.id);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(entry.isOnDuty ? 'Mark Off Duty' : 'Mark On Duty'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _showAddScheduleDialog(BuildContext context) {
    final employeeProvider = context.read<EmployeeProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();
    
    Employee? selectedEmployee;
    Division selectedDivision = _selectedDivision ?? Division.jail;
    String selectedShift = 'Day';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final availableEmployees = employeeProvider.getEmployeesByDivision(selectedDivision);
          
          return AlertDialog(
            title: const Text('Add Schedule Entry'),
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
                      setState(() => selectedEmployee = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedShift,
                    decoration: const InputDecoration(labelText: 'Shift'),
                    items: ['Day', 'Night', 'Swing']
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedShift = value);
                      }
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
                onPressed: selectedEmployee == null
                    ? null
                    : () {
                        scheduleProvider.addScheduleEntry(ScheduleEntry(
                          id: 'sched_${DateTime.now().millisecondsSinceEpoch}',
                          employee: selectedEmployee!,
                          division: selectedDivision,
                          date: _selectedDate,
                          shift: selectedShift,
                          isOnDuty: true,
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

  void _showEditScheduleDialog(BuildContext context, ScheduleEntry entry) {
    final scheduleProvider = context.read<ScheduleProvider>();
    String selectedShift = entry.shift;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Schedule: ${entry.employee.fullName}'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Division'),
                  subtitle: Text(entry.division.displayName),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedShift,
                  decoration: const InputDecoration(labelText: 'Shift'),
                  items: ['Day', 'Night', 'Swing']
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedShift = value);
                    }
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
                scheduleProvider.updateScheduleEntry(
                  entry.copyWith(shift: selectedShift),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
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
}
