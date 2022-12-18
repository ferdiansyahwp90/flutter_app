class UriNetwork {
  final String baseUrl = 'http://192.168.1.5:8000/api';

  //before login
  final String uriLogin = '/auth/login';
  final String uriRegister = '/auth/register';

  //after login
  final String uriLogout = '/auth/logout';
  final String uriCategory = '/categories';
}
