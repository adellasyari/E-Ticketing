import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.count,
    required this.gradientStart,
    required this.gradientEnd,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(icon, size: 70, color: Colors.white.withOpacity(0.2)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TicketStatusBadge extends StatelessWidget {
  final String status;

  const TicketStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'menunggu' ||
        lowerStatus == 'waiting' ||
        lowerStatus == 'open') {
      bgColor = const Color(0xFFFFF8E1); // yellow 50
      textColor = const Color(0xFFFBC02D); // yellow 700
    } else if (lowerStatus == 'diproses' ||
        lowerStatus == 'processing' ||
        lowerStatus == 'in progress') {
      bgColor = const Color(0xFFE3F2FD); // blue 50
      textColor = const Color(0xFF1E88E5); // blue 600
    } else if (lowerStatus == 'selesai' ||
        lowerStatus == 'closed' ||
        lowerStatus == 'done') {
      bgColor = const Color(0xFFE8F5E9); // green 50
      textColor = const Color(0xFF43A047); // green 600
    } else {
      bgColor = Colors.grey.shade200;
      textColor = Colors.grey.shade700;
      final theme = Theme.of(context);
      if (theme.brightness == Brightness.dark) {
        bgColor = Colors.grey.shade800;
        textColor = Colors.grey.shade300;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() +
            status.substring(1).toLowerCase(), // Capitalize first letter
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
