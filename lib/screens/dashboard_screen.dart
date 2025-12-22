import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';

/// Dashboard screen showing staffing overview for Patrol division only
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// Determine which shift is currently active based on time
  String _getCurrentShiftType() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Days: 6:00 AM - 6:00 PM (6-17)
    // Split: 12:00 PM - 12:00 AM (12-23) - overlaps with Days and Night, only one person
    // Night: 6:00 PM - 6:00 AM (18-23, 0-5)
    // Priority: Split > Days/Night for overlapping times
    if (hour >= 12 && hour < 24) {
      return 'Split';
    } else if (hour >= 6 && hour < 18) {
      return 'Days';
    } else {
      return 'Night';
    }
  }

  /// Get the current shift group (A or B) - simplified for demo
  String _getCurrentShiftGroup() {
    // In a real app, this would track actual rotation schedule
    // For demo purposes, alternate based on day of year:
    // - Week 0, 2, 4, ... = A shift
    // - Week 1, 3, 5, ... = B shift
    // Each week starts on day 0 (Jan 1st) and increments by 7 days
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return (dayOfYear ~/ 7) % 2 == 0 ? 'A' : 'B';
  }

  String _getCurrentShiftName() {
    final group = _getCurrentShiftGroup();
    final type = _getCurrentShiftType();
    return '$group-$type';
  }

  @override
  Widget build(BuildContext context) {
    final currentShiftName = _getCurrentShiftName();

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
          final allPatrolStaff = scheduleProvider.getCurrentlyOnDuty(Division.patrol);
          final currentShiftStaff = allPatrolStaff
              .where((entry) => entry.shift == currentShiftName)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patrol Division - Current Shift',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Real-time view of Patrol staff currently on duty',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Patrol Division',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Current Shift: $currentShiftName',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
                            Text(
                              'On Duty Now (${currentShiftStaff.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (currentShiftStaff.isEmpty)
                              const Text(
                                'No staff currently on duty for this shift',
                                style: TextStyle(color: Colors.grey),
                              )
                            else
                              ...currentShiftStaff.map((entry) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.blue.withOpacity(0.2),
                                          child: Text(
                                            entry.employee.rank,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            '${entry.employee.rank} ${entry.employee.lastName} #${entry.employee.badgeNumber}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
