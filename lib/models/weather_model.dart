final conditionToAnimationDay = {
  // ☀️ Clear & Cloudy
  'Sunny': 'sunnyday',
  'Partly cloudy': 'cloudyday',
  'Cloudy': 'cloudyday',
  'Overcast': 'overcast',
  'Mist': 'foggyday',
  'Fog': 'foggyday',
  'Freezing fog': 'foggyday',

  // 🌧️ Light Rain
  'Patchy light drizzle': 'lightrainday',
  'Light drizzle': 'lightrainday',
  'Freezing drizzle': 'lightrainday',
  'Patchy light rain': 'lightrainday',
  'Light rain': 'lightrainday',
  'Light rain shower': 'lightrainday',
  'Light sleet': 'lightrainday',
  'Patchy rain possible': 'lightrainday',
  'Light freezing rain': 'lightrainday',
  'Patchy sleet possible': 'lightrainday',
  'Ice pellets': 'lightrainday',
  'Light sleet shower': 'lightrainday',
  'Light showers of ice pellets': 'lightrainday',
  'Torrential rain shower': 'lightrainday',
  'Moderate rain at times': 'lightrainday',

  // 🌧️ Heavy Rain
  'Heavy rain': 'heavyrain',
  'Heavy rain at times': 'heavyrain',
  'Heavy freezing drizzle': 'heavyrain',
  'Moderate rain': 'heavyrain',
  'Moderate or heavy rain shower': 'heavyrain',
  'Moderate or heavy freezing rain': 'heavyrain',
  'Moderate or heavy sleet showers': 'heavyrain',
  'Moderate or heavy showers of ice pellets': 'heavyrain',
  'Moderate or heavy sleet': 'heavyrain',

  // ❄️ Snow
  'Patchy snow possible': 'snowyday',
  'Patchy light snow': 'snowyday',
  'Light snow': 'snowyday',
  'Blowing snow': 'snowyday',
  'Patchy moderate snow': 'snowyday',
  'Moderate snow': 'snowyday',
  'Patchy heavy snow': 'snowyday',
  'Heavy snow': 'snowyday',
  'Light snow shower': 'snowyday',
  'Moderate or heavy snow shower': 'snowyday',

  // ⚡ Thunder
  'Patchy light rain with thunder': 'thunderstorm',
  'Moderate or heavy rain with thunder': 'thunderstorm',
  'Patchy light snow with thunder': 'thunderstorm',
  'Moderate or heavy snow with thunder': 'thunderstorm',
  'Thundery outbreaks possible': 'thunderstorm',

  // ❄️ Blizzard
  'Blizzard': 'blizzard',

  // Default
  'default': 'sunnyday',
};

final conditionToAnimationNight = {
  // ☀️ Clear & Cloudy
  'Clear': 'clearnight',
  'Partly cloudy': 'cloudynight',
  'Cloudy': 'cloudynight',
  'Overcast': 'overcast',
  'Mist': 'foggyday',
  'Fog': 'foggyday',
  'Freezing fog': 'foggyday',

  // 🌧️ Light Rain
  'Patchy light drizzle': 'lightrainnight',
  'Light drizzle': 'lightrainnight',
  'Freezing drizzle': 'lightrainnight',
  'Patchy light rain': 'lightrainnight',
  'Light rain': 'lightrainnight',
  'Light rain shower': 'lightrainnight',
  'Light sleet': 'lightrainnight',
  'Patchy rain possible': 'lightrainnight',
  'Light freezing rain': 'lightrainnight',
  'Patchy sleet possible': 'lightrainnight',
  'Ice pellets': 'lightrainnight',
  'Light sleet shower': 'lightrainnight',
  'Light showers of ice pellets': 'lightrainnight',
  'Torrential rain shower': 'lightrainnight',
  'Moderate rain at times': 'lightrainnight',

  // 🌧️ Heavy Rain
  'Heavy rain': 'heavyrain',
  'Heavy rain at times': 'heavyrain',
  'Heavy freezing drizzle': 'heavyrain',
  'Moderate rain': 'heavyrain',
  'Moderate or heavy rain shower': 'heavyrain',
  'Moderate or heavy freezing rain': 'heavyrain',
  'Moderate or heavy sleet showers': 'heavyrain',
  'Moderate or heavy showers of ice pellets': 'heavyrain',
  'Moderate or heavy sleet': 'heavyrain',

    // ❄️ Snow
  'Patchy snow possible': 'snowynight',
  'Patchy light snow': 'snowynight',
  'Light snow': 'snowynight',
  'Blowing snow': 'snowynight',
  'Patchy moderate snow': 'snowynight',
  'Moderate snow': 'snowynight',
  'Patchy heavy snow': 'snowynight',
  'Heavy snow': 'snowynight',
  'Light snow shower': 'snowynight',
  'Moderate or heavy snow shower': 'snowynight',

  // ⚡ Thunder
  'Patchy light rain with thunder': 'thunderstorm',
  'Moderate or heavy rain with thunder': 'thunderstorm',
  'Patchy light snow with thunder': 'thunderstorm',
  'Moderate or heavy snow with thunder': 'thunderstorm',
  'Thundery outbreaks possible': 'thunderstorm',

  // ❄️ Blizzard
  'Blizzard': 'blizzard',

  // Default
  'default': 'clearnight',
};

class WeatherModel {
  final String isDay;
  final String country;
  final String city;
  final String feelslike;
  final String iconCode;
  final String condition;
  final String temperature;
  final String wind;
  final String humidity;
  final List<List<String>> forecastCurrentDay;
  final List<List<String>> forecastFutureDays;
  final String cloud;
  final String dewpoint;
  final String precipitation;
  final String visibility;
  final String heatIndex;
  final String sunrise;
  final String sunset;
  final String moonphase;

  WeatherModel({
    required this.heatIndex,
    required this.sunrise,
    required this.sunset,
    required this.moonphase,
    required this.city,
    required this.visibility,
    required this.precipitation,
    required this.forecastFutureDays,
    required this.forecastCurrentDay,
    required this.condition,
    required this.country,
    required this.feelslike,
    required this.iconCode,
    required this.isDay,
    required this.temperature,
    required this.wind,
    required this.cloud,
    required this.humidity,
    required this.dewpoint,
  });
}

