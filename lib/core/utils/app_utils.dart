class AppUtils {
  AppUtils._();

  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  static String formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map(capitalize).join(' ');
  }
}
