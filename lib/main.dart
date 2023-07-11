import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

@immutable
class Person {
  final String name;
  final int age;
  final String uuid;

  Person({
    required this.name,
    required this.age,
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v4();

  @override
  String toString() => "Person(uuid: $uuid, name:$name, age:$age)";

  @override
  operator ==(covariant Person other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  Person updated([String? name, int? age]) {
    return Person(
      name: name ?? this.name,
      age: age ?? this.age,
      uuid: uuid,
    );
  }

  String get showName => "$name ($age years old)";
}

class DataModel extends ChangeNotifier {
  final List<Person> _people = [];
  int get count => _people.length;
  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);

  void add(Person addPerson) {
    _people.add(addPerson);
    notifyListeners();
  }

  void remove(Person removePerson) {
    _people.remove(removePerson);
    notifyListeners();
  }

  void update(Person updatePerson) {
    final index = _people.indexOf(updatePerson);
    final oldPerson = _people[index];
    if (oldPerson.name != updatePerson.name ||
        oldPerson.age != updatePerson.age) {
      _people[index] = oldPerson.updated(
        updatePerson.name,
        updatePerson.age,
      );
      notifyListeners();
    }
  }
}

final peopleProvider = ChangeNotifierProvider<DataModel>((ref) => DataModel());

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
      body: Consumer(
        builder: (context, ref, child) {
          final dataModel = ref.watch(peopleProvider);
          return ListView.builder(
            itemCount: dataModel.count,
            itemBuilder: (context, index) {
              final people = dataModel.people[index];
              return ListTile(
                title: Text(people.showName),
                onTap: () async {
                  final updatedPerson =
                      await showCreateOrUpdateDialog(context, people);
                  if (updatedPerson != null) {
                    dataModel.update(updatedPerson);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final person = await showCreateOrUpdateDialog(context);
          if (person != null) {
            final dataModel = ref.read(peopleProvider);
            dataModel.add(person);
          }
        },
      ),
    );
  }
}

final nameController = TextEditingController();
final ageController = TextEditingController();

Future<Person?> showCreateOrUpdateDialog(
  BuildContext context, [
  Person? updatePerson,
]) {
  String? name = updatePerson?.name;
  int? age = updatePerson?.age;

  nameController.text = name ?? '';
  ageController.text = age?.toString() ?? '';

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create or update Person"),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Enter the name here...",
              ),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(
                hintText: "Enter the age here...",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(null),
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () {
              if (name != null && age != null) {
                final newName = nameController.text;
                final newAge = int.tryParse(ageController.text)!;
                if (updatePerson != null) {
                  final newPerson = updatePerson.updated(newName, newAge);
                  Navigator.of(context).pop(
                    newPerson,
                  );
                }
              } else {
                Navigator.of(context).pop(
                  Person(
                    name: nameController.text,
                    age: int.tryParse(ageController.text)!,
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
