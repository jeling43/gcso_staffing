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
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => _showGenerateSchedulesDialog(context),
                  label: const Text('Generate Schedules'),
                  icon: const Icon(Icons.auto_awesome),
                  heroTag: 'generate',
                ),
                const SizedBox(height: 16),
                FloatingActionButton.extended(
                  onPressed: () => _showAddScheduleDialog(context),
                  label: const Text('Add Schedule'),
                  icon: const Icon(Icons.add),
                  heroTag: 'add',
                ),
              ],
            )
          : null,
    );
  }

  List<Widget> _buildScheduleCards(
    BuildContext context,
    ScheduleProvider scheduleProvider,
    bool isSupervisor,
  ) {
    // Only show Patrol division entries
    final entries = scheduleProvider.getScheduleByDivision(
      Division.patrol,
      date: _selectedDate,
    );

    return [
      Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Patrol Division',
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
      ),
    ];
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
    String selectedShift = Shift.day;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final availableEmployees = employeeProvider.getEmployeesByDivision(Division.patrol);
          
          return AlertDialog(
            title: const Text('Add Schedule Entry'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    leading: Icon(Icons.directions_car),
                    title: Text('Division: Patrol'),
                    dense: true,
                  ),
                  const SizedBox(height: 8),
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
                    items: const [
                      DropdownMenuItem(value: Shift.day, child: Text('Day')),
                      DropdownMenuItem(value: Shift.night, child: Text('Night')),
                      DropdownMenuItem(value: Shift.split1200, child: Text('Split-1200')),
                      DropdownMenuItem(value: Shift.split1400, child: Text('Split-1400')),
                    ],
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
                          division: Division.patrol,
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
                  items: const [
                    DropdownMenuItem(value: Shift.day, child: Text('Day')),
                    DropdownMenuItem(value: Shift.night, child: Text('Night')),
                    DropdownMenuItem(value: Shift.split1200, child: Text('Split-1200')),
                    DropdownMenuItem(value: Shift.split1400, child: Text('Split-1400')),
                  ],
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

  void _showGenerateSchedulesDialog(BuildContext context) {
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final employeeProvider = context.read<EmployeeProvider>();
          final employees = employeeProvider.getEmployeesByDivision(Division.patrol);
          final eligibleEmployees = employees.where(
            (e) => e.shiftGroup != null && e.shiftType != null
          ).length;
          
          return AlertDialog(
            title: const Text('Generate Schedules'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Automatically create schedule entries for all employees based on their shift group assignments and the swing rotation pattern.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Start Date'),
                    subtitle: Text(DateFormat('EEEE, MMMM d, yyyy').format(startDate)),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          startDate = date;
                          if (endDate.isBefore(startDate)) {
                            endDate = startDate.add(const Duration(days: 30));
                          }
                        });
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('End Date'),
                    subtitle: Text(DateFormat('EEEE, MMMM d, yyyy').format(endDate)),
                    onTap: () async {
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
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preview:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('• Date range: ${endDate.difference(startDate).inDays + 1} days'),
                        Text('• Eligible employees: $eligibleEmployees'),
                        Text('• Estimated entries: ~${((endDate.difference(startDate).inDays + 1) * eligibleEmployees / 2).round()}'),
                      ],
                    ),
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
                  Navigator.pop(context);
                  _generateSchedules(context, startDate, endDate);
                },
                child: const Text('Generate'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _generateSchedules(BuildContext context, DateTime startDate, DateTime endDate) {
    final employeeProvider = context.read<EmployeeProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();
    
    int entriesCreated = 0;
    final employees = employeeProvider.getEmployeesByDivision(Division.patrol);
    
    // Loop through each date
    for (var date = startDate; 
         date.isBefore(endDate) || date.isAtSameMomentAs(endDate); 
         date = date.add(const Duration(days: 1))) {
      // Determine which shift group is working
      final workingShiftGroup = ShiftGroup.getWorkingShiftGroup(date);
      
      // Create entries for employees in the working shift group
      for (final employee in employees) {
        if (employee.shiftGroup == workingShiftGroup && 
            employee.shiftType != null && 
            employee.division == Division.patrol) {
          
          // Check if entry already exists (avoid duplicates)
          final existingEntries = scheduleProvider.getScheduleForDate(date);
          final alreadyExists = existingEntries.any((e) => 
            e.employee.id == employee.id && 
            e.date.year == date.year && 
            e.date.month == date.month && 
            e.date.day == date.day
          );
          
          if (!alreadyExists) {
            scheduleProvider.addScheduleEntry(ScheduleEntry(
              id: 'sched_${employee.id}_${date.toIso8601String()}',
              employee: employee,
              division: Division.patrol,
              date: date,
              shift: employee.shiftType!,
              isOnDuty: true,
            ));
            entriesCreated++;
          }
        }
      }
    }
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generated $entriesCreated schedule entries'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
