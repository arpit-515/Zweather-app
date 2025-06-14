import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/screens/loading_screen.dart';
import 'package:weather_app/screens/weather_current.dart';
import 'package:weather_app/screens/weather_forecast.dart';
import 'package:weather_app/provider/providers.dart';
import 'package:weather_app/widgets/internet_check_wrapper.dart';
import 'package:location/location.dart';

class WeatherHome extends ConsumerStatefulWidget {
  const WeatherHome({super.key});

  @override
  ConsumerState<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends ConsumerState<WeatherHome> {
  final Location location = Location();
  bool _isLoading = true;

  Future<void> _requestLocationPermission() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
      }

      if (!serviceEnabled) return;

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
      }

      if (permissionGranted == PermissionStatus.deniedForever ||
          permissionGranted == PermissionStatus.denied) {
        return;
      }
      
      final locationData = await location.getLocation();

      if (locationData.latitude != null && locationData.longitude != null) {
        final lat = locationData.latitude!.toString().substring(0, 5);
        final lon = locationData.longitude!.toString().substring(0, 5);
        ref.read(cityName.notifier).state = '$lat,$lon';
      } else {
        ref.read(cityName.notifier).state = 'Delhi';
      }
    } catch (e) {
      debugPrint("Permission error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    final connection = ref.watch(internetConnectionProvider);

    return connection.when(
      data: (connected) {
        if (!connected) {
          return InternetCheckWrapper(
            onRetry: () => _requestLocationPermission(),
            child: const SizedBox.shrink(),
          );
        }
        final displayPage = ref.watch(activePage);

        return WillPopScope(
          onWillPop: () async {
            if (displayPage == 'forecast' || displayPage == 'weather_forecast_page') {
              ref.read(activePage.notifier).state = 'current_weather_page';
              return false; // Prevent app from closing
            }
            return true; // Allow app to close if already on main page
          },
          child: _isLoading
              ? const Scaffold(body: Center(child: SplashScreen()))
              : Scaffold(
                  body: PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder:
                        (child, animation, secondaryAnimation) =>
                            FadeThroughTransition(
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              child: child,
                            ),
                    child: displayPage == 'current_weather_page'
                        ? const WeatherCurrent(key: ValueKey('current'))
                        : const WeatherForecast(key: ValueKey('forecast')),
                  ),
                ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(body: Center(child: Text("Couldn't check internet."))),
    );
  }
}