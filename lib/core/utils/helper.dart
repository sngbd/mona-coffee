import 'package:intl/intl.dart';

class Helper {
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour <= 12) {
      return 'Good Morning';
    } else if (hour >= 13 && hour <= 18) {
      return 'Good Afternoon';
    } else if (hour >= 18 && hour <= 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String formatCurrency(num value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

}
