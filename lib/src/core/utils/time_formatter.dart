import 'package:intl/intl.dart';

class TimeFormatter {
  /// Formats a DateTime into a relative time string
  /// Examples: "Just now", "5m ago", "2h ago", "3d ago"
  static String getRelativeTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '';
    }

    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.isNegative) {
        return 'Just now';
      }

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}w';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months}mo';
      } else {
        final years = (difference.inDays / 365).floor();
        return '${years}y';
      }
    } catch (e) {
      return '';
    }
  }

  /// Formats a DateTime into a full readable date
  /// Example: "Oct 24, 2023"
  static String formatFullDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '';
    }

    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('MMM d, yyyy').format(dateTime);
    } catch (e) {
      return dateTimeString; // Return original if parsing fails
    }
  }
}
