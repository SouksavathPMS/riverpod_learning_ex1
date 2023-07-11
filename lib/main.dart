import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

const List<String> names = [
  'Alice',
  'Bob',
  'Charlie',
  'David',
  'Eve',
  'Frank',
  'Grace',
  'Henry',
  'Ivy',
  'Jack'
];

final tickerProvider = StreamProvider<int>(
  (ref) => Stream.periodic(
    const Duration(seconds: 1),
    (i) => i + 1,
  ),
);

final namesProvider = StreamProvider((ref) {
  return ref.watch(tickerProvider.future).asStream().map(
        (event) => names.getRange(0, event),
      );
});

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

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameStream = ref.watch(namesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stream Builder"),
      ),
      body: nameStream.when(
        data: (data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(data.elementAt(index)),
            ),
          );
        },
        error: (error, stackTrace) => const Text("Done"),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
