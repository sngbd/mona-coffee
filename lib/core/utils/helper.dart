class Helper {
  static String getGreeting() {
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
}
