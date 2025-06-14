import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;
import 'package:weather_app/screens/loading_screen.dart';
import 'package:weather_app/widgets/glassbox.dart';
import 'package:weather_app/provider/providers.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_api_service.dart';
import 'package:weather_app/widgets/searchbar.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class WeatherCurrent extends ConsumerWidget {
  const WeatherCurrent({super.key});

  Future<void> _refreshData(WidgetRef ref) async {
    ref.read(weatherRefreshProvider.notifier).state++;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(cityName);
    final now = DateTime.now();
    final time = DateFormat.jm().format(now);
    final date = DateFormat('EEE, dd MMMM').format(now);
    final refreshCount = ref.watch(weatherRefreshProvider);

    if (city.isEmpty) {
      return const Scaffold(body: Center(child: SplashScreen()));
    }

    return FutureBuilder<WeatherModel>(
      key: ValueKey(refreshCount),
      future: WeatherService().getWeather(city, ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SplashScreen());
        }

        if (snapshot.hasError) {
          final errorMsg = snapshot.error.toString();
          if (errorMsg.contains('SocketException')) {
            return Container(
              decoration: BoxDecoration(color: Colors.blueGrey),
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

        final isday = weatherData.isDay == '1';
        final condition = weatherData.condition;
        final String animation =
            isday
                ? (conditionToAnimationDay[condition] ??
                    conditionToAnimationDay['default']!)
                : (conditionToAnimationNight[condition] ??
                    conditionToAnimationNight['default']!);
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;
        double dragStartX = 0;
        bool isThunder = false;
        if (animation == 'thunderstorm') {
          isThunder = true;
        }
        return RefreshIndicator(
          onRefresh: () => _refreshData(ref),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return NotificationListener<ScrollNotification>(
                onNotification: (notification) => false,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Stack(
                        children: [
                          rive.RiveAnimation.asset(
                            'assets/animations/$animation.riv',
                            fit: BoxFit.cover,
                          ),
                          Visibility(
                            visible: isThunder,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: LottieBuilder.asset(
                                'assets/animations/lightning.json',
                              ),
                            ),
                          ),
                          Align(
                            alignment: const Alignment(0, -0.5),
                            child: GestureDetector(
                              onTap: () {
                                ref
                                    .read(glassBoxContentProvider.notifier)
                                    .state = !ref.read(glassBoxContentProvider);
                              },
                              onHorizontalDragStart: (details) {
                                dragStartX = details.localPosition.dx;
                              },
                              onHorizontalDragEnd: (details) {
                                dragStartX = 0;
                              },
                              onHorizontalDragUpdate: (details) {
                                double dragEndX = details.localPosition.dx;
                                double dragDistance = dragEndX - dragStartX;
                                if (dragDistance.abs() > 50) {
                                  ref.read(activePage.notifier).state =
                                      'weather_forecast_page';
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: GlassBox(
                                height: height * 0.62,
                                width: width * 0.858,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 1000),
                                  transitionBuilder: (
                                    Widget child,
                                    Animation<double> animation,
                                  ) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  child: Consumer(
                                    builder: (context, ref, _) {
                                      final showMain = ref.watch(
                                        glassBoxContentProvider,
                                      );
                                      if (showMain) {
                                        return Center(
                                          key: const ValueKey('main'),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: const Alignment(
                                                  1,
                                                  -1,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  child: ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(
                                                          maxWidth: 300,
                                                        ),
                                                    child: const IntrinsicWidth(
                                                      child: CitySearchBar(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: const Alignment(
                                                  0,
                                                  -0.4,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Text(
                                                          '${weatherData.temperature}°C',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 72,
                                                            foreground:
                                                                Paint()
                                                                  ..style =
                                                                      PaintingStyle
                                                                          .stroke
                                                                  ..strokeWidth =
                                                                      2
                                                                  ..color =
                                                                      Colors
                                                                          .black,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${weatherData.temperature}°C',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 72,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    FittedBox(
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Image.network(
                                                            'http:${weatherData.iconCode}',
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text.rich(
                                                            TextSpan(
                                                              text:
                                                                  weatherData
                                                                      .condition,
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                shadows: [
                                                                  Shadow(
                                                                    offset:
                                                                        Offset(
                                                                          0,
                                                                          0,
                                                                        ),
                                                                    blurRadius:
                                                                        3,
                                                                    color:
                                                                        Colors
                                                                            .black,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            softWrap: true,
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: const Alignment(
                                                  0,
                                                  0.3,
                                                ),
                                                child: Divider(
                                                  color: Colors.blueGrey
                                                      .withAlpha(200),
                                                  thickness: 2,
                                                  indent: 30,
                                                  endIndent: 30,
                                                ),
                                              ),
                                              Align(
                                                alignment: const Alignment(
                                                  -0.8,
                                                  0.54,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Text(
                                                          weatherData.feelslike,
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            foreground:
                                                                Paint()
                                                                  ..style =
                                                                      PaintingStyle
                                                                          .stroke
                                                                  ..strokeWidth =
                                                                      2
                                                                  ..color =
                                                                      Colors
                                                                          .black,
                                                          ),
                                                        ),
                                                        Text(
                                                          weatherData.feelslike,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 20,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Text(
                                                      'FEELS LIKE',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: const Alignment(
                                                  -0.3,
                                                  0.5,
                                                ),
                                                child: VerticalDivider(
                                                  color: Colors.blueGrey
                                                      .withAlpha(200),
                                                  thickness: 2,
                                                  indent: 400,
                                                  endIndent: 100,
                                                ),
                                              ),
                                              Align(
                                                alignment: const Alignment(
                                                  0,
                                                  0.57,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Text(
                                                          weatherData.wind,
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            foreground:
                                                                Paint()
                                                                  ..style =
                                                                      PaintingStyle
                                                                          .stroke
                                                                  ..strokeWidth =
                                                                      2
                                                                  ..color =
                                                                      Colors
                                                                          .black,
                                                          ),
                                                        ),
                                                        Text(
                                                          weatherData.wind,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 20,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Text(
                                                      'WIND\nkm/h',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: const Alignment(
                                                  0.3,
                                                  0.5,
                                                ),
                                                child: VerticalDivider(
                                                  color: Colors.blueGrey
                                                      .withAlpha(200),
                                                  thickness: 2,
                                                  indent: 400,
                                                  endIndent: 100,
                                                ),
                                              ),
                                              Align(
                                                alignment: const Alignment(
                                                  0.8,
                                                  0.53,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Text(
                                                          weatherData.humidity,
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            foreground:
                                                                Paint()
                                                                  ..style =
                                                                      PaintingStyle
                                                                          .stroke
                                                                  ..strokeWidth =
                                                                      2
                                                                  ..color =
                                                                      Colors
                                                                          .black,
                                                          ),
                                                        ),
                                                        Text(
                                                          weatherData.humidity,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 20,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Text(
                                                      'HUMIDITY',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: const Alignment(
                                                  1,
                                                  0.9,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Text(
                                                      'SWIPE FOR FORECAST',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_ios_outlined,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: const Alignment(
                                                  -1,
                                                  -1,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    20,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Text(
                                                            time,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              foreground:
                                                                  Paint()
                                                                    ..style =
                                                                        PaintingStyle
                                                                            .stroke
                                                                    ..strokeWidth =
                                                                        0.5
                                                                    ..color =
                                                                        Colors
                                                                            .black,
                                                            ),
                                                          ),
                                                          Text(
                                                            time,
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              color:
                                                                  Colors
                                                                      .blueGrey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Stack(
                                                        children: [
                                                          Text(
                                                            date,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              foreground:
                                                                  Paint()
                                                                    ..style =
                                                                        PaintingStyle
                                                                            .stroke
                                                                    ..strokeWidth =
                                                                        0.5
                                                                    ..color =
                                                                        Colors
                                                                            .black,
                                                            ),
                                                          ),
                                                          Text(
                                                            date,
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              color:
                                                                  Colors
                                                                      .blueGrey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Stack(
                                                        children: [
                                                          Text(
                                                            '📍$city',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              foreground:
                                                                  Paint()
                                                                    ..style =
                                                                        PaintingStyle
                                                                            .stroke
                                                                    ..strokeWidth =
                                                                        0.5
                                                                    ..color =
                                                                        Colors
                                                                            .black,
                                                            ),
                                                          ),
                                                          Text(
                                                            '📍$city',
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              color:
                                                                  Colors
                                                                      .blueGrey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          key: const ValueKey('alt'),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: const Alignment(
                                                  1,
                                                  -1,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  child: ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(
                                                          maxWidth: 300,
                                                        ),
                                                    child: const IntrinsicWidth(
                                                      child: Expanded(
                                                        child: CitySearchBar(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: const Alignment(
                                                  1,
                                                  0.9,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Text(
                                                      'SWIPE FOR FORECAST',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_ios_outlined,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment: const Alignment(
                                                  -1,
                                                  -1,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    20,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Text(
                                                            time,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              foreground:
                                                                  Paint()
                                                                    ..style =
                                                                        PaintingStyle
                                                                            .stroke
                                                                    ..strokeWidth =
                                                                        0.5
                                                                    ..color =
                                                                        Colors
                                                                            .black,
                                                            ),
                                                          ),
                                                          Text(
                                                            time,
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              color:
                                                                  Colors
                                                                      .blueGrey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Stack(
                                                        children: [
                                                          Text(
                                                            date,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              foreground:
                                                                  Paint()
                                                                    ..style =
                                                                        PaintingStyle
                                                                            .stroke
                                                                    ..strokeWidth =
                                                                        0.5
                                                                    ..color =
                                                                        Colors
                                                                            .black,
                                                            ),
                                                          ),
                                                          Text(
                                                            date,
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              color:
                                                                  Colors
                                                                      .blueGrey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Stack(
                                                        children: [
                                                          Text(
                                                            '📍$city',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              foreground:
                                                                  Paint()
                                                                    ..style =
                                                                        PaintingStyle
                                                                            .stroke
                                                                    ..strokeWidth =
                                                                        0.5
                                                                    ..color =
                                                                        Colors
                                                                            .black,
                                                            ),
                                                          ),
                                                          Text(
                                                            '📍$city',
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                              color:
                                                                  Colors
                                                                      .blueGrey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Precipitation.....${weatherData.precipitation}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Clouds.....${weatherData.cloud}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Visibility.....${weatherData.visibility}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Heat Index.....${weatherData.heatIndex}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Dew Point.....${weatherData.dewpoint}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Moon Phase.....${weatherData.moonphase}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Sunrise.....${weatherData.sunrise}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Sunset.....${weatherData.sunset}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 80,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: GlassBox(
                                width: width * 0.858,
                                height: height * 0.18,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount:
                                      weatherData.forecastCurrentDay.length,
                                  itemBuilder: (context, index) {
                                    final hour =
                                        weatherData.forecastCurrentDay[index];
                                    final time = DateFormat.j().format(
                                      DateTime.parse(hour[0]),
                                    );
                                    final temp = '${hour[1]}°';
                                    final icon = 'http:${hour[3]}';
                                    final rain = '${hour[5]}%';

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            time,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Image.network(icon, width: 40),
                                          const SizedBox(height: 2),
                                          Text(
                                            temp,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$rain ☔',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
