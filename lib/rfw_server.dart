import 'package:flutter/material.dart';
import 'package:remote_hot_reload/src/server.dart';

Future<void> main() async {
  // RFW client app: https://remote-hot-reload.web.app/client/
  // RFW text viewer: https://remote-hot-reload.web.app/text_viewer/
  await runRemoteApp(
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
              Title("Hello!"),
              Title("Amusement rides"),
              Space(),
              Rides(),
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
    return Text(title,
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ));
  }
}

class Rides extends StatelessWidget {
  const Rides({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final ride in ['Magic Land', 'Cosmic Mountain', 'Animal Land'])
          Ride(
            ride,
          ),
      ],
    );
  }
}

class Ride extends StatelessWidget {
  const Ride(
    this.name, {
    super.key,
    // required this.image,
  });

  final String name;
  // final String image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 20.0,
          ),
        ),
        const Space(),
        Image.network(
          'https://source.unsplash.com/random/200x200/?${Uri.encodeComponent('roller coaster${' ' * name.length}')}',
          width: 200.0,
          height: 200.0,
        ),
        const Space(),
        ElevatedButton(
          child: const Text('Reserve'),
          onPressed: () => debugPrint('event "pressed" {"ride":$name}'),
        ),
      ],
    );
  }
}
