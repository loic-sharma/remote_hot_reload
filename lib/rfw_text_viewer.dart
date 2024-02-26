import 'dart:async';

import 'package:flutter/material.dart';
import 'package:remote_hot_reload/src/logic.dart';

Future<void> main() async {
  await firebase.start();

  runApp(const RfwTextViewer());
}

class RfwTextViewer extends StatefulWidget {
  const RfwTextViewer({
    super.key,
  });

  @override
  State<RfwTextViewer> createState() => _RfwTextViewerState();
}

class _RfwTextViewerState extends State<RfwTextViewer> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = rfw.text;
    rfw.addListener(_onRfwChanged);
  }

  @override
  void dispose() {
    rfw.removeListener(_onRfwChanged);
    textController.dispose();
    super.dispose();
  }

  void _onRfwChanged() {
    textController.text = rfw.text;
  }

  Future<void> _save() async {
    await firebase.updateRfw(textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RFW text viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('RFW text viewer'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textController,
                  maxLines: null,
                ),
              ),
      
              const SizedBox(height: 20.0),
      
              ListenableBuilder(
                listenable: rfw,
                builder: (BuildContext context, Widget? child) {
                  if (rfw.updating) {
                    return const SizedBox.square(
                      dimension: 100.0,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
      
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _save,
          tooltip: 'Save',
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}
