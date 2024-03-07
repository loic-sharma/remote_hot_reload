# Remote hot reload

Remote hot reload: changing the "server" app's Dart code updates clients.

[YouTube demo video](https://www.youtube.com/watch?v=iKiMp0T3kBw)

The "server" app is a regular Flutter app that swapped its `runApp`
with `runRemoteApp`:

```dart
Future<void> main() async {
  await runRemoteApp(
    MaterialApp(
      // ...
      home: const Scaffold(
        body: Column(
          children: [
            // Supports all of Dart, including if and for expressions!
            for (final name in ['Foo', 'Bar'])
              // Supports custom widgets!
              Greeter(name),
          ],
        ),
      ),
    ),
  );
}

class Greeter extends StatelessWidget {
  const Greeter({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Text('Hello $name!');
}
```

How does it work? On each hot reload, the "server" app converts its Dart widget
tree to [RFW](https://pub.dev/packages/rfw) and then broadcasts it using
[Firebase](https://firebase.google.com/docs/database#realtime-database).
For more information, see the [Implementation details](#implementation-details)
section below.

## Background

### Out-of-store updates

Flutter's most upvoted issue is pushing out-of-store updates to apps:
[flutter#14330](https://github.com/flutter/flutter/issues/14330)

There are two solution categories:

1. **Code push** - Allows developers to push app updates directly to users' devices.
   See [shorebird.dev](https://shorebird.dev/).
2. **Server-driven UI** - Allows developers to _configure_ UIs remotely.
   For Flutter, that's done using
   [Remote Flutter Widgets ("RFW")](https://pub.dev/packages/rfw).

These solutions complement each other - apps can use both approaches to maximize
their user experience.

### Goal

RFW's configuration language is harder to learn and write than Dart.

This prototype examines if Dart can be used to configure RFW.

### RFW text

Flutter's solution for server-driven UI,
[RFW](https://pub.dev/packages/rfw), has an in-memory format that
can be configured using either a binary or text format.

Here's an RFW text example:

```dart
import core.widgets;

widget root { showNames: true } = switch state.showNames {
  false: Text(
    text: ["Hello everyone!"],
    textDirection: "ltr",
  ),
  true: Column(
    children: [
      ...for person in data.people:
        Text(
          text: ["Hello", person.name, "!"],
          textDirection: "ltr",
        ),
    ],
  ),
};
```

RFW text is similar to Dart but has some subtle differences. For example:

1. Dynamically typed. Similar to JavaScript, you don't get compilation errors if
   you access members that do not exist.
2. No `class`es. You use a novel `widget` syntax, with special syntax for state
3. No `if` expressions. You use `switch` instead
7. No enums. You use strings instead
4. No string interpolation. The `Text` widget accepts a list of strings
5. `for` and `switch` expressions don't need `(` and `)`
6. `for` expressions use `:` instead of `{` and `}`

Since RFW text is a new language, it does not have strong tooling yet. You don't
get syntax highlighting, code completion, or a language server providing rich
diagnostics.

Furthermore, RFW's widgets are different than Flutter's widgets. For example,
RFW's `Text` widget has a _named_ `text` parameter that accepts a list of strings;
Flutter's `Text` widget has a _positional_ `text` string parameter.

Combined, these make RFW text harder to learn and write than Dart.

## How to run the demo

1. In your Flutter framework repository, switch to the
[`dump_rfw` branch](https://github.com/loic-sharma/flutter/tree/dump_rfw):

   ```
   git remote add loic https://github.com/loic-sharma/flutter
   git fetch loic
   git checkout dump_rfw
   ```

2. In your checkout of this `remote_hot_reload` repository, ...
    1. Configure Firebase
        1. Create a [Firebase Realtime Database](https://firebase.google.com/docs/database)
        2. Install the [Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli)
        3. Log into Firebase:

           ```
           firebase login
           ```

        4. Install the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup?platform=web)

           ```
           dart pub global activate flutterfire_cli
           ```

        5. Configure the demo apps to use your Firebase project:

           ```
           flutterfire configure
           ```

    2. Run the demo!

       > ⚠️ Firebase Realtime Database does not support all Flutter platforms.
       > Target web on Windows and Linux machines.

        1. Run the client app:

           ```
           flutter run ./lib/rfw_client.dart
           ```

        2. Run the server app:

           ```
           flutter run ./lib/rfw_server.dart
           ```

            Pressing the `z` key in the `flutter run` command line will dump
            the app as RFW text.

        3. (Optional) To see the RFW text generated by the server app,
           run the RFW text viewer app:

           ```
           flutter run ./lib/rfw_text_viewer.dart
           ```

    3. Send some updates: edit the Flutter app in `lib/rfw_server.dart` and
       hot reload - the client updates automatically!

## Implementation details

> [!WARNING]
> This is an early prototype. Expect implementation details to change.

The implementation mirrors how DevTool's generates its widget summary
tree. It starts from the `WidgetsBinding.instance.rootElement`, recurses down,
and serializes "local" widgets. See
[`debugDumpRfw`](https://github.com/loic-sharma/flutter/blob/088cc1e582c8de8b840e5eaedf07ee2430dd36cb/packages/flutter/lib/src/widgets/binding.dart#L1242).

Widget serialization mirrors RFW's existing widget serialization: each supported
widget needs logic to map the widget to its RFW representation. For example:

1. Here's how the prototype serializes a `SizedBox`: [`loic-sharma/flutter@088cc1e/packages/flutter/lib/src/widgets/binding.dart#L1384-L1387`](https://github.com/loic-sharma/flutter/blob/088cc1e582c8de8b840e5eaedf07ee2430dd36cb/packages/flutter/lib/src/widgets/binding.dart#L1384-L1387)
2. Here's how RFW deserializes a `SizedBox`: [`flutter/packages@930318/packages/rfw/lib/src/flutter/core_widgets.dart#L607-L613`](https://github.com/flutter/packages/blob/930318a82735042d5dd0d9028a2e66826aaa4589/packages/rfw/lib/src/flutter/core_widgets.dart#L607-L613)

> [!NOTE]
> The logic to (de)serialize widgets and RFW is mostly basic mapping logic.
> In the future, Dart macros could reduce this boilerplate.

Finally, the server app saves the updated RFW text to Firebase on hot reload
events. See [`runRemoteApp`](https://github.com/loic-sharma/remote_hot_reload/blob/4c00cb530b4c9bc2f09990b352aa7f808c7b69f6/lib/src/server.dart#L4-L17) and its widget's
[`reassemble` method](https://github.com/loic-sharma/remote_hot_reload/blob/4c00cb530b4c9bc2f09990b352aa7f808c7b69f6/lib/src/server.dart#L33-L40).