import 'dart:async';

import 'package:flutter/material.dart';
import 'package:remote_hot_reload/src/logic.dart';
import 'package:rfw/formats.dart' show parseLibraryFile;
import 'package:rfw/rfw.dart';

void main() {
  unawaited(firebase.start());

  runApp(const RfwClient());
}

class RfwClient extends StatefulWidget {
  const RfwClient({super.key});

  @override
  State<RfwClient> createState() => _RfwClientState();
}

class _RfwClientState extends State<RfwClient> {
  static const LibraryName coreName = LibraryName(<String>['core', 'widgets']);
  static const LibraryName materialName = LibraryName(<String>['material', 'widgets']);
  static const LibraryName mainName = LibraryName(<String>['main']);

  final Runtime _runtime = Runtime();
  final DynamicContent _data = DynamicContent();

  RemoteWidgetLibrary? _remoteWidgets;

  @override
  void initState() {
    super.initState();
    // Local widget library:
    _runtime.update(coreName, createCoreWidgets());
    _runtime.update(materialName, createMaterialWidgets());
    rfw.addListener(_onRfwChanged);
  }

  @override
  void dispose() {
    rfw.removeListener(_onRfwChanged);
    super.dispose();
  }

  void _onRfwChanged() {
    setState(() {
      if (!rfw.updating) {
        _remoteWidgets = parseLibraryFile(rfw.text);
        _runtime.update(mainName, _remoteWidgets!);

        // TODO?
        _data.update('greet', <String, Object>{'name': 'World'});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const loading = SizedBox.square(
      dimension: 100.0,
      child: Center(child: CircularProgressIndicator()),
    );

    Widget body = loading;
    if (!rfw.updating) {
      body = RemoteWidget(
        runtime: _runtime,
        data: _data,
        widget: const FullyQualifiedWidgetName(mainName, 'root'),
        onEvent: (String name, DynamicMap arguments) {
          debugPrint('user triggered event "$name" with data: $arguments');
        },
      );
    }

    return MaterialApp(
      title: 'RFW client app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('RFW client app'),
        ),
        body: body,
      ),
    );
  }
}
