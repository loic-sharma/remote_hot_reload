import 'package:flutter/material.dart';
import 'package:remote_hot_reload/src/logic.dart';

Future<void> runRemoteAppServer(Widget app) async {
  await firebase.start();

  runApp(
    _RemoteAppServer(
      child: app
    ),
  );
}

class _RemoteAppServer extends StatefulWidget {
  const _RemoteAppServer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<_RemoteAppServer> createState() => _RemoteAppServerState();
}

class _RemoteAppServerState extends State<_RemoteAppServer> {
  @override
  void reassemble() {
    super.reassemble();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final rfwText = dumpRfw();
      firebase.updateRfw(rfwText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
