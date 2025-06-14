import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/provider/providers.dart';
import 'package:rive/rive.dart' as rive;
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_api_service.dart';
import 'package:weather_app/screens/loading_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/widgets/glassbox.dart';

class WeatherForecast extends ConsumerWidget {
  const WeatherForecast({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(cityName);
    final refreshCount = ref.watch(weatherRefreshProvider);

    return FutureBuilder<WeatherModel>(
      key: ValueKey(refreshCount),
      future: WeatherService().getWeather(city, ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SplashScreen());
        }

        if (snapshot.hasError) {
          final errorMsg = snapshot.error.toString();
          if (errorMsg.contains('SocketException') ||
              errorMsg.contains('No internet connection')) {
            return Container(
              decoration: const BoxDecoration(color: Colors.blueGrey),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LottieBuilder.asset('assets/animations/no_internet.json'),
                    const Text(
                      "No Internet Connection",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () =>
                              ref.read(weatherRefreshProvider.notifier).state++,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(child: Text('Error: $errorMsg'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }
        final weatherData = snapshot.data!;
        final condition = weatherData.forecastFutureDays[0][4];
        final isDay = weatherData.isDay == '1';
        final String animation =
            isDay
                ? (conditionToAnimationDay[condition] ??
                    conditionToAnimationDay['default']!)
                : (conditionToAnimationNight[condition] ??
                    conditionToAnimationNight['default']!);
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;
        double dragStartX = 0;

        return GestureDetector(
          onHorizontalDragStart:
              (details) => dragStartX = details.localPosition.dx,
          onHorizontalDragEnd: (_) => dragStartX = 0,
          onHorizontalDragUpdate: (details) {
            final dragEndX = details.localPosition.dx;
            if ((dragEndX - dragStartX).abs() > 50) {
              ref.read(activePage.notifier).state = 'current_weather_page';
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              IgnorePointer(
                child: rive.RiveAnimation.asset(
                  'assets/animations/$animation.riv',
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: Alignment(0, -0.7),
                child: GlassBox(
                  height: height * 0.4,
                  width: width * 0.858,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment(0, -0.4),
                        child: Stack(
                          children: [
                            Text(
                              '${weatherData.forecastFutureDays[0][0]}/${weatherData.forecastFutureDays[0][2]}°C',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                                foreground:
                                    Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 1
                                      ..color = Colors.black,
                              ),
                            ),
                            Text(
                              '${weatherData.forecastFutureDays[0][0]}/${weatherData.forecastFutureDays[0][2]}°C',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            weatherData.forecastFutureDays[0][1],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment(0, 0.1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                              'http:${weatherData.forecastFutureDays[0][5]}',
                              height: height * 0.1,
                              width: width * 0.1,
                              fit: BoxFit.contain,
                            ),
                            Text(
                              weatherData.forecastFutureDays[0][4],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0, 0.3),
                        child: Divider(
                          color: Colors.blueGrey.withAlpha(200),
                          thickness: 2,
                          indent: 30,
                          endIndent: 30,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.8, 0.70),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Text(
                                  weatherData.forecastFutureDays[0][7],
                                  style: TextStyle(
                                    fontSize: 12,
                                    foreground:
                                        Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 2
                                          ..color = Colors.black,
                                  ),
                                ),
                                Text(
                                  weatherData.forecastFutureDays[0][7],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'PRECIP.\nIN mm',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.3, 0.5),
                        child: VerticalDivider(
                          color: Colors.blueGrey.withAlpha(200),
                          thickness: 2,
                          indent: 220,
                          endIndent: 20,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0, 0.70),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Text(
                                  weatherData.forecastFutureDays[0][6],
                                  style: TextStyle(
                                    fontSize: 12,
                                    foreground:
                                        Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 2
                                          ..color = Colors.black,
                                  ),
                                ),
                                Text(
                                  weatherData.forecastFutureDays[0][6],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'WIND\nkm/h',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.3, 0.5),
                        child: VerticalDivider(
                          color: Colors.blueGrey.withAlpha(200),
                          thickness: 2,
                          indent: 220,
                          endIndent: 20,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.8, 0.70),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Text(
                                  '${weatherData.forecastFutureDays[0][3]}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    foreground:
                                        Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 2
                                          ..color = Colors.black,
                                  ),
                                ),
                                Text(
                                  '${weatherData.forecastFutureDays[0][3]}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'CHANCE\nOF RAIN',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0.7),
                child: GlassBox(
                  height: height * 0.4,
                  width: width * 0.858,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment(0, -0.4),
                        child: Stack(
                          children: [
                            Text(
                              '${weatherData.forecastFutureDays[1][0]}/${weatherData.forecastFutureDays[1][2]}°C',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                                foreground:
                                    Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 1
                                      ..color = Colors.black,
                              ),
                            ),
                            Text(
                              '${weatherData.forecastFutureDays[1][0]}/${weatherData.forecastFutureDays[1][2]}°C',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            weatherData.forecastFutureDays[1][1],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment(0, 0.1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                              'http:${weatherData.forecastFutureDays[1][5]}',
                              height: height * 0.1,
                              width: width * 0.1,
                              fit: BoxFit.contain,
                            ),
                            Text(
                              weatherData.forecastFutureDays[1][4],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0, 0.3),
                        child: Divider(
                          color: Colors.blueGrey.withAlpha(200),
                          thickness: 2,
                          indent: 30,
                          endIndent: 30,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.8, 0.70),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Text(
                                  weatherData.forecastFutureDays[1][7],
                                  style: TextStyle(
                                    fontSize: 12,
                                    foreground:
                                        Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 2
                                          ..color = Colors.black,
                                  ),
                                ),
                                Text(
                                  weatherData.forecastFutureDays[1][7],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'PRECIP.\nIN mm',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.3, 0.5),
                        child: VerticalDivider(
                          color: Colors.blueGrey.withAlpha(200),
                          thickness: 2,
                          indent: 220,
                          endIndent: 20,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0, 0.70),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Text(
                                  weatherData.forecastFutureDays[1][6],
                                  style: TextStyle(
                                    fontSize: 12,
                                    foreground:
                                        Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 2
                                          ..color = Colors.black,
                                  ),
                                ),
                                Text(
                                  weatherData.forecastFutureDays[1][6],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'WIND\nkm/h',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.3, 0.5),
                        child: VerticalDivider(
                          color: Colors.blueGrey.withAlpha(200),
                          thickness: 2,
                          indent: 220,
                          endIndent: 20,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.8, 0.70),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Text(
                                  '${weatherData.forecastFutureDays[1][3]}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    foreground:
                                        Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 2
                                          ..color = Colors.black,
                                  ),
                                ),
                                Text(
                                  '${weatherData.forecastFutureDays[1][3]}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'CHANCE\nOF RAIN',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
