import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(),
    );
  }
}

extension OptionalInfixAddition<T extends num> on T? {
  T? operator +(T? other) {
    final showdow = this;
    if (showdow != null) {
      return showdow + (other ?? 0) as T?;
    } else {
      return null;
    }
  }
}

enum City {
  stockholm,
  paris,
  tokyo,
}

typedef WeatherEimoji = String;
Future<WeatherEimoji> getWeather(City city) async {
  return Future.delayed(
    const Duration(seconds: 1),
    () => {
      City.stockholm: "❄️",
      City.paris: "☔️",
      City.tokyo: "⛅️",
    }[city]!,
  );
}

final weatherProvider = StateProvider<City?>((ref) => null);
final currentWeatherProvider = FutureProvider<String>((ref) async {
  final currentWeather = ref.watch(weatherProvider);
  if (currentWeather != null) {
    return getWeather(currentWeather);
  } else {
    return "🤷🏻‍♂️";
  }
});

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(currentWeatherProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Future Builder (Weater)"),
      ),
      body: Column(
        children: [
          currentWeather.when(
            data: (data) => Text(
              data,
              style: const TextStyle(fontSize: 40),
            ),
            error: (error, stackTrace) => const Text(
              "😢",
              style: TextStyle(fontSize: 40),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: City.values.length,
            itemBuilder: (context, index) {
              final cityTitle = City.values[index];
              final isSelected = cityTitle == ref.watch(weatherProvider);
              return ListTile(
                title: Text(cityTitle.name),
                trailing: !isSelected ? null : const Icon(Icons.check),
                onTap: () {
                  ref.read(weatherProvider.notifier).state = cityTitle;
                },
              );
            },
          ))
        ],
      ),
    );
  }
}
