// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

@immutable
class Film {
  final String id;
  final String title;
  final String description;
  final bool isFavorite;
  const Film({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavorite,
  });

  Film copy(bool favorite) => Film(
        id: id,
        title: title,
        description: description,
        isFavorite: favorite,
      );

  @override
  String toString() {
    return 'Film(id: $id,'
        'title: $title,'
        'description: $description,'
        'isFavorite: $isFavorite)';
  }

  @override
  operator ==(covariant Film other) =>
      id == other.id && isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hashAll([id, isFavorite]);
}

List<Film> allFilms = [
  const Film(
    id: "1",
    title: "Oppenheiber",
    description: "The newest movie",
    isFavorite: false,
  ),
  const Film(
    id: "2",
    title: "Inception",
    description: "The great movie",
    isFavorite: false,
  ),
  const Film(
    id: "3",
    title: "Interstella",
    description: "The best space movie",
    isFavorite: false,
  ),
  const Film(
    id: "4",
    title: "Dunkirk",
    description: "The best soilder movie",
    isFavorite: false,
  ),
];

class FilmNotifier extends StateNotifier<List<Film>> {
  FilmNotifier() : super(allFilms);

  void update(Film newFilm, bool isFavorite) {
    state = state
        .map(
          (anyFilm) =>
              anyFilm.id == newFilm.id ? anyFilm.copy(isFavorite) : anyFilm,
        )
        .toList();
  }
}

enum FavoriteStatus {
  all,
  favorite,
  norFavorite,
}

final favoriteStatusProvider = StateProvider<FavoriteStatus>((ref) {
  return FavoriteStatus.all;
});

final allFilmProvider = StateNotifierProvider<FilmNotifier, List<Film>>(
  (ref) => FilmNotifier(),
);

final favoriteFilmsProvider = Provider<List<Film>>((ref) {
  return ref
      .watch(allFilmProvider)
      .where((element) => element.isFavorite)
      .toList();
});

final notFavoriteFilmsProvider = Provider<List<Film>>((ref) {
  return ref
      .watch(allFilmProvider)
      .where((element) => !element.isFavorite)
      .toList();
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

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a person"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const FilteredWidget(),
          Consumer(
            builder: (context, ref, child) {
              final filter = ref.watch(favoriteStatusProvider);
              switch (filter) {
                case FavoriteStatus.all:
                  return FilmsWidget(providerBase: allFilmProvider);
                case FavoriteStatus.favorite:
                  return FilmsWidget(providerBase: favoriteFilmsProvider);
                case FavoriteStatus.norFavorite:
                  return FilmsWidget(providerBase: notFavoriteFilmsProvider);
              }
            },
          )
        ],
      ),
    );
  }
}

class FilmsWidget extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> providerBase;
  const FilmsWidget({
    Key? key,
    required this.providerBase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(providerBase);
    return Expanded(
      child: ListView.builder(
        itemCount: films.length,
        itemBuilder: (context, index) {
          final film = films.elementAt(index);
          final filmFavoriteIcon = film.isFavorite
              ? const Icon(Icons.favorite)
              : const Icon(Icons.favorite_border);
          return ListTile(
            title: Text(film.title),
            subtitle: Text(film.description),
            trailing: IconButton(
              onPressed: () {
                final isFavorite = !film.isFavorite;
                ref.read(allFilmProvider.notifier).update(film, isFavorite);
              },
              icon: filmFavoriteIcon,
            ),
          );
        },
      ),
    );
  }
}

class FilteredWidget extends StatelessWidget {
  const FilteredWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DropdownButton(
          value: ref.watch(favoriteStatusProvider),
          items: FavoriteStatus.values
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(
                    status.name.split(".").last,
                  ),
                ),
              )
              .toList(),
          onChanged: (FavoriteStatus? value) {
            ref.read(favoriteStatusProvider.notifier).state = value!;
          },
        );
      },
    );
  }
}
