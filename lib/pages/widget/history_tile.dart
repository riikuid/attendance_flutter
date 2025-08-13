import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presence_app/theme.dart';
import '../../../models/attendance.dart';

class HistoryTile extends StatelessWidget {
  final Attendance item;
  const HistoryTile({super.key, required this.item});

  String _formatDurationHM(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final inStr = DateFormat('HH:mm').format(item.checkInAt.toLocal());
    final outStr =
        item.checkOutAt != null
            ? DateFormat('HH:mm').format(item.checkOutAt!.toLocal())
            : '—';
    final totalStr =
        item.checkOutAt != null
            ? _formatDurationHM(
              item.checkOutAt!.toUtc().difference(item.checkInAt.toUtc()),
            )
            : '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5.0,
            spreadRadius: 0.3,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(right: 8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd').format(item.checkInAt.toLocal()),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'MMM',
                      ).format(item.checkInAt.toLocal()).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: semibold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: _labelValue('Check-in', inStr)),
                  VerticalDivider(
                    color: subtitle1TextColor,
                    thickness: 0.5,
                    width: 30,
                    indent: 8,
                    endIndent: 8,
                  ),
                  Expanded(child: _labelValue('Check-out', outStr)),
                  VerticalDivider(
                    color: subtitle1TextColor,
                    thickness: 0.5,
                    width: 30,
                    indent: 8,
                    endIndent: 8,
                  ),
                  Expanded(child: _labelValue('Total', totalStr)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: subtitle1TextColor)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: semibold,
            color: blackColor,
          ),
        ),
      ],
    );
  }
}
