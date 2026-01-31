import 'package:flutter/material.dart';
import '../models/models.dart';

/// Card widget displaying shift staffing information
class ShiftCard extends StatelessWidget {
  final String shift;

  // Modern color palette
  static const Color _primaryNavy = Color(0xFF1E3A5F);

  const ShiftCard({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    final color = _getShiftColor(shift);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getShiftIcon(shift),
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  '$shift Shift',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getShiftIcon(String shift) {
    switch (shift) {
      case Shift.day:
        return Icons.wb_sunny_rounded;
      case Shift.night:
        return Icons.nightlight_round;
      case Shift.split1200:
      case Shift.split1400:
        return Icons.schedule_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  Color _getShiftColor(String shift) {
    switch (shift) {
      case Shift.day:
        return const Color(0xFFF59E0B);  // Modern amber
      case Shift.night:
        return const Color(0xFF4F46E5);  // Modern indigo
      case Shift.split1200:
      case Shift.split1400:
        return const Color(0xFF8B5CF6);  // Modern purple
      default:
        return _primaryNavy;
    }
  }
}
