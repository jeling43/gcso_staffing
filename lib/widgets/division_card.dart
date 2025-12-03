import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';

/// Card widget displaying division staffing information
class DivisionCard extends StatelessWidget {
  final Division division;

  const DivisionCard({super.key, required this.division});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScheduleProvider, OnCallProvider>(
      builder: (context, scheduleProvider, onCallProvider, _) {
        final onDutyStaff = scheduleProvider.getCurrentlyOnDuty(division);
        final onCallAssignment = onCallProvider.getOnCallForDivision(division);

        return Card(
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _getDivisionColor(division),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDivisionIcon(division),
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            division.displayName,
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
                      ...onDutyStaff.take(5).map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: _getDivisionColor(division).withAlpha(51),
                                  child: Text(
                                    entry.employee.firstName[0] + entry.employee.lastName[0],
                                    style: TextStyle(
                                      color: _getDivisionColor(division),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.employee.fullName,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '${entry.shift} Shift',
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
                    if (onDutyStaff.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '+ ${onDutyStaff.length - 5} more',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    const Divider(height: 24),
                    const Text(
                      'On-Call',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (onCallAssignment != null)
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              onCallAssignment.employee.fullName,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'No on-call assignment',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
