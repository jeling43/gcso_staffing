import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';

/// Card widget displaying shift staffing information
class ShiftCard extends StatelessWidget {
  final String shift;

  const ShiftCard({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, _) {
        final onDutyStaff = scheduleProvider.getCurrentlyOnDutyByShift(shift);

        return Card(
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _getShiftColor(shift),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getShiftIcon(shift),
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$shift Shift',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${onDutyStaff.length} currently on duty',
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
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (onDutyStaff.isEmpty)
                      const Text(
                        'No staff currently on duty',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ...onDutyStaff.map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: _getShiftColor(shift).withOpacity(0.2),
                                  child: Text(
                                    entry.employee.rank,
                                    style: TextStyle(
                                      color: _getShiftColor(shift),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${entry.employee.rank} ${entry.employee.lastName} #${entry.employee.badgeNumber}',
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      if (entry.employee.isSupervisor)
                                        Text(
                                          'Supervisor',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
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
      },
    );
  }

  IconData _getShiftIcon(String shift) {
    switch (shift) {
      case 'Day':
        return Icons.wb_sunny;
      case 'Night':
        return Icons.nightlight;
      case 'Split':
        return Icons.schedule;
      default:
        return Icons.access_time;
    }
  }

  Color _getShiftColor(String shift) {
    switch (shift) {
      case 'Day':
        return Colors.amber;
      case 'Night':
        return Colors.indigo;
      case 'Split':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
