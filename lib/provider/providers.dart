import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final activePage = StateProvider<String>((ref) {
  return 'current_weather_page';
});
final currentWeather = Provider<String>((ref) {
  return 'current_weather';
});
final cityName = StateProvider<String>((ref) {
  return '';
});
final weatherRefreshProvider = StateProvider<int>((ref) => 0);
final glassBoxContentProvider = StateProvider<bool>((ref) => true);

final internetConnectionProvider = StreamProvider<bool>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((event) => event != ConnectivityResult.none)
      .distinct();
});