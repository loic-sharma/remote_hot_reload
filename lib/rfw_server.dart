import 'package:flutter/material.dart';
import 'package:remote_hot_reload/src/server.dart';

void main() async {
  await runRemoteAppServer(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Column(
            children: [
              Space(),
              Title('Hello!'),
              Title("What's your favorite city?"),
              Space(),
              FavoriteCities(),
            ],
          ),
        ),
      ),
    ),
  );
}

class Space extends StatelessWidget {
  const Space({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 30.0);
  }
}

class Title extends StatelessWidget {
  const Title(
    this.title, {
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      )
    );
  }
}

class FavoriteCities extends StatelessWidget {
  const FavoriteCities({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final city in ['San Francisco', 'New York', 'Los Angeles'])
          City(
            city,
            image: 'https://source.unsplash.com/random/200x200/?${Uri.encodeComponent(city.toLowerCase())}',
          ),
      ],
    );
  }
}

class City extends StatelessWidget {
  const City(
    this.name, {
    super.key,
    required this.image,
  });

  final String name;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 14.0,
          ),
        ),

        const Space(),

        Image.network(
          image,
          width: 200.0,
          height: 200.0,
        ),

        const Space(),

        ElevatedButton(
          child: Text('I like $name'),
          onPressed: () {
            debugDumpRfw();
            debugPrint('TODO: event "pressed" {"city":$name}');
          },
        ),
      ],
    );
  }
}
