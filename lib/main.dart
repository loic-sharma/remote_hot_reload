import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        rfwNotifier: RfwConfiguration(rfwTxt: 'Hello world'),
      ),
    );
  }
}

abstract interface class RfwNotifier with ChangeNotifier {
  bool get updating;

  String get rfwTxt;

  Future<void> updateRfwTxt(String rfwTxt);
}

class RfwConfiguration with ChangeNotifier implements RfwNotifier {
  RfwConfiguration({
    required String rfwTxt
  }) : _rfwTxt = rfwTxt;

  @override
  bool get updating => _updating;
  bool _updating = false;

  @override
  String get rfwTxt => _rfwTxt;
  String _rfwTxt;
  set rfwTxt(String value) {
    _rfwTxt = value;
    notifyListeners();
  }

  @override
  Future<void> updateRfwTxt(String rfwTxt) async {
    assert(_updating == false);

    _updating = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _updating = false;
    _rfwTxt = rfwTxt;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.rfwNotifier,
  });

  final RfwNotifier rfwNotifier;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    textController.text = widget.rfwNotifier.rfwTxt;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MyHomePage oldWidget) {
    textController.text = widget.rfwNotifier.rfwTxt;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.rfwNotifier.updating) {
      return;
    }

    await widget.rfwNotifier.updateRfwTxt(textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              controller: textController,
              maxLines: null,
            ),

            const SizedBox(height: 20.0),

            ListenableBuilder(
              listenable: widget.rfwNotifier,
              builder: (BuildContext context, Widget? child) {
                if (widget.rfwNotifier.updating) {
                  return const CircularProgressIndicator();
                }

                return Text(
                  widget.rfwNotifier.rfwTxt,
                );
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
    );
  }
}
