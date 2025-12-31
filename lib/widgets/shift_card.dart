import 'package:flutter/material.dart';
import '../models/models.dart';

/// Card widget displaying shift staffing information
class ShiftCard extends StatelessWidget {
  final String shift;

  const ShiftCard({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: _getShiftColor(shift),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _getShiftIcon(shift),
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '$shift Shift',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getShiftIcon(String shift) {
    switch (shift) {
      case Shift.day:
        return Icons.wb_sunny;
      case Shift.night:
        return Icons.nightlight;
      case Shift.split1200:
      case Shift.split1400:
        return Icons.schedule;
      default:
        return Icons.access_time;
    }
  }

  Color _getShiftColor(String shift) {
    switch (shift) {
      case Shift.day:
        return Colors.amber;
      case Shift.night:
        return Colors.indigo;
      case Shift.split1200:
      case Shift.split1400:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
