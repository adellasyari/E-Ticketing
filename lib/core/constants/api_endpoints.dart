class ApiEndpoints {
  static const String base =
      'https://api-dummy.com/api'; // update for real backend

  static const String login = '$base/auth/login';
  static const String logout = '$base/auth/logout';
  static const String profile = '$base/user/profile';
  static const String tickets = '$base/tickets';
}
