import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/provider/providers.dart';

class CitySearchBar extends ConsumerWidget {
  const CitySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    void updateCity() {
      final input = controller.text.trim();
      if (input.isNotEmpty) {
        ref.read(cityName.notifier).state = input;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please enter a city name")));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter City',
              filled: true,
              fillColor: Colors.white.withAlpha(51),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: Colors.blueGrey),
            onSubmitted: (_) => updateCity(),
          ),
        ),
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: updateCity,
        ),
      ],
    );
  }
}
