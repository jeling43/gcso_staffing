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

    // Group entries by shift type
    final shiftGroups = <String, List<ScheduleEntry>>{};
    for (final entry in entries) {
      shiftGroups.putIfAbsent(entry.shift, () => []).add(entry);
    }

    // Define shift order
    final shiftOrder = [Shift.day, Shift.night, Shift.split1200, Shift.split1400];
    
    return shiftOrder.where((shift) => shiftGroups.containsKey(shift)).map((shift) {
      final shiftEntries = shiftGroups[shift]!;
      final onDutyCount = shiftEntries.where((e) => e.isOnDuty).length;
      
      return Card(
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
                    Icons.access_time,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${shift} Shift',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    '$onDutyCount on duty',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            ...shiftEntries.map((entry) => _buildScheduleEntryTile(
                  context,
                  entry,
                  isSupervisor,
                  scheduleProvider,
                )),
            if (isSupervisor)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: OutlinedButton.icon(
                  onPressed: () => _showAddFillInDialog(context, shift),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Fill-in'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
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
    // Determine visual styling based on employee status
    final isAbsent = !entry.isOnDuty;
    final isTemporary = entry.isTemporary;
    
    // Visual distinction for temporary employees
    final backgroundColor = isTemporary ? Colors.blue.withOpacity(0.05) : null;
    final leadingIcon = isTemporary ? '👥' : '👤';
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: isTemporary 
            ? Border.all(color: Colors.blue.withOpacity(0.3), style: BorderStyle.solid)
            : null,
      ),
      child: ListTile(
        leading: isAbsent
            ? CircleAvatar(
                backgroundColor: Colors.grey[400],
                child: Text(
                  entry.employee.firstName[0] + entry.employee.lastName[0],
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : CircleAvatar(
                backgroundColor: isTemporary ? Colors.blue[300] : Colors.green,
                child: Text(
                  leadingIcon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
        title: Text(
          isAbsent ? '${entry.employee.fullName} (Absent)' : entry.employee.fullName,
          style: TextStyle(
            color: isAbsent ? Colors.grey : null,
            decoration: isAbsent ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${entry.shift} Shift • Badge: ${entry.employee.badgeNumber}${isTemporary ? ' • Fill-in' : ''}',
          style: TextStyle(color: isAbsent ? Colors.grey : null),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAbsent)
              Chip(
                label: Text(isTemporary ? 'Fill-in' : 'On Duty'),
                backgroundColor: isTemporary ? Colors.blue[100] : Colors.green[100],
              ),
            if (isSupervisor) ...[
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'markAbsent') {
                    scheduleProvider.markEmployeeAbsent(entry.id, true);
                  } else if (value == 'markPresent') {
                    scheduleProvider.markEmployeeAbsent(entry.id, false);
                  } else if (value == 'removeFillIn') {
                    scheduleProvider.removeScheduleEntry(entry.id);
                  } else if (value == 'edit') {
                    _showEditScheduleDialog(context, entry);
                  } else if (value == 'remove') {
                    scheduleProvider.removeScheduleEntry(entry.id);
                  }
                },
                itemBuilder: (context) {
                  final menuItems = <PopupMenuEntry<String>>[];
                  
                  if (isTemporary) {
                    // Temporary employees: show "Remove Fill-in"
                    menuItems.add(const PopupMenuItem(
                      value: 'removeFillIn',
                      child: Text('Remove Fill-in'),
                    ));
                  } else if (isAbsent) {
                    // Absent employees: show "Mark Present"
                    menuItems.add(const PopupMenuItem(
                      value: 'markPresent',
                      child: Text('Mark Present'),
                    ));
                  } else {
                    // Regular employees on duty: show "Mark Absent"
                    menuItems.add(const PopupMenuItem(
                      value: 'markAbsent',
                      child: Text('Mark Absent'),
                    ));
                  }
                  
                  // Add Edit and Remove for all entries
                  menuItems.add(const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ));
                  menuItems.add(const PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove'),
                  ));
                  
                  return menuItems;
                },
              ),
            ],
          ],
        ),
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
                          isTemporary: false,
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
         !date.isAfter(endDate); 
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
            e.employee.id == employee.id
          );
          
          if (!alreadyExists) {
            scheduleProvider.addScheduleEntry(ScheduleEntry(
              id: 'sched_${employee.id}_${date.toIso8601String()}',
              employee: employee,
              division: Division.patrol,
              date: date,
              shift: employee.shiftType!,
              isOnDuty: true,
              isTemporary: false,
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

  void _showAddFillInDialog(BuildContext context, String shift) {
    final employeeProvider = context.read<EmployeeProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();
    
    Employee? selectedEmployee;
    String searchQuery = '';
    String employmentStatusFilter = EmploymentStatus.all; // 'All', 'Full-time', 'Part-time'
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Show ALL employees in the system, not just those in Patrol
          final allEmployees = employeeProvider.employees;
          
          // Filter employees based on search and employment status
          final filteredEmployees = allEmployees.where((employee) {
            // Search filter (case-insensitive)
            final matchesSearch = searchQuery.isEmpty ||
                employee.firstName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                employee.lastName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                employee.badgeNumber.toLowerCase().contains(searchQuery.toLowerCase());
            
            // Employment status filter
            final bool matchesStatus;
            if (employmentStatusFilter == EmploymentStatus.all) {
              matchesStatus = true; // Show all employees including those with null status
            } else if (employmentStatusFilter == EmploymentStatus.fullTime) {
              matchesStatus = employee.employmentStatus == EmploymentStatus.fullTime;
            } else if (employmentStatusFilter == EmploymentStatus.partTime) {
              matchesStatus = employee.employmentStatus == EmploymentStatus.partTime;
            } else {
              // Fallback for unexpected values
              matchesStatus = false;
            }
            
            return matchesSearch && matchesStatus;
          }).toList();
          
          return AlertDialog(
            title: Text('Add Fill-in to $shift Shift'),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select any employee to temporarily add to this shift for ${DateFormat('MMMM d, yyyy').format(_selectedDate)}.',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // Search field
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      hintText: 'Search by name or badge number',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Employment status filter
                  Row(
                    children: [
                      const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: Text(EmploymentStatus.all),
                              selected: employmentStatusFilter == EmploymentStatus.all,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => employmentStatusFilter = EmploymentStatus.all);
                                }
                              },
                            ),
                            ChoiceChip(
                              label: Text(EmploymentStatus.fullTime),
                              selected: employmentStatusFilter == EmploymentStatus.fullTime,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => employmentStatusFilter = EmploymentStatus.fullTime);
                                }
                              },
                            ),
                            ChoiceChip(
                              label: Text(EmploymentStatus.partTime),
                              selected: employmentStatusFilter == EmploymentStatus.partTime,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => employmentStatusFilter = EmploymentStatus.partTime);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Employee count
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Showing ${filteredEmployees.length} employee${filteredEmployees.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Scrollable list of employees
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: filteredEmployees.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text('No employees found'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredEmployees.length,
                            itemBuilder: (context, index) {
                              final employee = filteredEmployees[index];
                              final isSelected = selectedEmployee?.id == employee.id;
                              
                              return InkWell(
                                onTap: () {
                                  setState(() => selectedEmployee = employee);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blue.shade50 : null,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isSelected ? Colors.blue : Colors.grey[400],
                                      child: Icon(
                                        isSelected ? Icons.check : Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      '${employee.fullName} (#${employee.badgeNumber})',
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${employee.shiftAssignment}${employee.employmentStatus != null ? ' • ${employee.employmentStatus}' : ''}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(Icons.check_circle, color: Colors.blue)
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Fill-ins are temporary and can be removed at any time.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
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
                onPressed: selectedEmployee == null
                    ? null
                    : () {
                        // Generate unique ID using employee ID, date, shift, and timestamp
                        final uniqueId = 'fillin_${selectedEmployee!.id}_${_selectedDate.toIso8601String()}_${shift}_${DateTime.now().millisecondsSinceEpoch}';
                        scheduleProvider.addScheduleEntry(ScheduleEntry(
                          id: uniqueId,
                          employee: selectedEmployee!,
                          division: Division.patrol,
                          date: _selectedDate,
                          shift: shift,
                          isOnDuty: true,
                          isTemporary: true,
                        ));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${selectedEmployee!.fullName} as fill-in'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                child: const Text('Add Fill-in'),
              ),
            ],
          );
        },
      ),
    );
  }
}
