import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';

/// Dashboard screen showing staffing overview by shift
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// Get current shift type based on current time
  String _getCurrentShiftType() {
    final now = DateTime.now();
    final hour = now.hour;

    // Split-1400 takes priority: 14:00-02:00 (2 PM to 2 AM)
    if (hour >= 14 || hour < 2) {
      return Shift.split1400;
    }
    // Split-1200: 12:00-24:00 (12 PM to midnight)
    else if (hour >= 12 && hour < 24) {
      return Shift.split1200;
    }
    // Days: 6:00-18:00
    else if (hour >= 6 && hour < 18) {
      return Shift.day;
    }
    // Night: 18:00-06:00 (and 0:00-6:00)
    else {
      return Shift.night;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final workingShiftGroup = ShiftGroup.getWorkingShiftGroup(today);
    final currentShiftType = _getCurrentShiftType();
    
    // Determine colors based on shift group
    final isAShift = workingShiftGroup == ShiftGroup.a;
    final gradientColors = isAShift 
        ? [Colors.amber.shade700, Colors.amber.shade500]
        : [Colors.blue.shade700, Colors.blue.shade500];
    final shadowColor = isAShift 
        ? Colors.amber.shade700.withOpacity(0.4)
        : Colors.blue.shade700.withOpacity(0.4);
    final badgeColor = isAShift 
        ? Colors.amber.shade700
        : Colors.blue.shade700;
    
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
          final currentShiftStaff = scheduleProvider.getCurrentlyOnDutyByShift(currentShiftType);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prominent Current Shift Section
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'CURRENT SHIFT',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$workingShiftGroup SHIFT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${currentShiftStaff.length} ON DUTY',
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (currentShiftStaff.isNotEmpty)
                        ...currentShiftStaff.map((entry) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: Text(
                                  entry.employee.rank,
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${entry.employee.rank} ${entry.employee.lastName}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Badge #${entry.employee.badgeNumber}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'No staff currently on duty',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // All Patrol Shifts Today Section
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
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
                const SizedBox(height: 16),
                Text(
                  'All Patrol Shifts Today',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                
                // Days Shift
                _buildShiftSummaryCard(
                  context,
                  scheduleProvider,
                  'Days Shift',
                  Shift.day,
                  Icons.wb_sunny,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                
                // Split Shift 1200
                _buildShiftSummaryCard(
                  context,
                  scheduleProvider,
                  'Split Shift 1200',
                  Shift.split1200,
                  Icons.schedule,
                  Colors.purple,
                  maxStaff: 1,
                ),
                const SizedBox(height: 12),
                
                // Split Shift 1400
                _buildShiftSummaryCard(
                  context,
                  scheduleProvider,
                  'Split Shift 1400',
                  Shift.split1400,
                  Icons.access_alarm,
                  Colors.deepPurple,
                  maxStaff: 1,
                ),
                const SizedBox(height: 12),
                
                // Night Shift
                _buildShiftSummaryCard(
                  context,
                  scheduleProvider,
                  'Night Shift',
                  Shift.night,
                  Icons.nightlight_round,
                  Colors.indigo,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShiftSummaryCard(
    BuildContext context,
    ScheduleProvider scheduleProvider,
    String shiftName,
    String shiftType,
    IconData icon,
    Color color, {
    int? maxStaff,
  }) {
    final staffList = scheduleProvider.getCurrentlyOnDutyByShift(shiftType);
    final isAtCapacity = maxStaff != null && staffList.length >= maxStaff;
    
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shiftName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        Shift.getDisplayName(shiftType),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (maxStaff != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${staffList.length}/$maxStaff',
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${staffList.length}',
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Warning banner for at-capacity split shifts
          if (isAtCapacity)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'At Maximum Capacity',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
                const Text(
                  'On Duty Staff',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                if (staffList.isEmpty)
                  const Text(
                    'No staff currently on duty',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  )
                else
                  ...staffList.map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: color.withOpacity(0.2),
                              child: Text(
                                entry.employee.rank,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${entry.employee.rank} ${entry.employee.lastName} #${entry.employee.badgeNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
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
    );
  }
}
