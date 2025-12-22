import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Dashboard screen showing staffing overview by shift
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final workingShiftGroup = ShiftGroup.getWorkingShiftGroup(today);
    
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
                Text(
                  'Patrol Division - Shift Overview',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Working Today: $workingShiftGroup Shift',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Swing Schedule: 3 on, 2 off, 2 on, 3 off',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),
                // Day Shift Card
                ShiftCard(shift: Shift.day),
                const SizedBox(height: 16),
                // Night Shift Card
                ShiftCard(shift: Shift.night),
                const SizedBox(height: 16),
                // Split Shift Card
                ShiftCard(shift: Shift.split),
              ],
            ),
          );
        },
      ),
    );
  }
}
