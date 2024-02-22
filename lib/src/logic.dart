import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

final rfw = RfwController();
final firebase = FirebaseFake();

class FirebaseFake {
  Future<void> start() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    rfw.text = '''
import core.widgets;
import material.widgets;

widget root = Text(
  text: 'Hello world',
  style: {
      fontSize: 20.0,
      fontWeight: 'bold',
  },
);
''';
  }

  Future<void> updateRfw(String text) async {
    await rfw.update(text, () async {
      await Future<void>.delayed(const Duration(seconds: 1));
    });
  }
}

class FirebaseWorker {
  final _rfwTextRef = FirebaseDatabase.instance.ref("rfwText");

  Future<void> start() async {
    await Firebase.initializeApp(
      // TODO
      // options: DefaultFirebaseOptions.currentPlatform,
    );

    // Read the initial RFW text value.
    final snapshot = await _rfwTextRef.get();
    if (snapshot.exists) {
      rfw.text = snapshot.value.toString();
    } else {
      rfw.text = '';
    }

    // Listen for changes to the RFW text value.
    _rfwTextRef.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        rfw.text = data.toString();
    });
  }

  Future<void> updateRfw(String text) async {
    await rfw.update(text, () async {
      await _rfwTextRef.set(text);
    });
  }
}

abstract interface class RfwNotifier with ChangeNotifier {
  bool get updating;

  String get text;
}

class RfwController with ChangeNotifier implements RfwNotifier {
  RfwController();

  @override
  bool get updating => _updating;
  bool _updating = true;

  @override
  String get text => _text;
  String _text = '';
  set text(String value) {
    _updating = false;
    _text = value;
    notifyListeners();
  }

  Future<void> update(String text, Future<void> Function() update) async {
    if (_updating) {
      throw 'Update already in progress!';
    }

    final previous = _text;
    _updating = true;
    _text = text;
    notifyListeners();

    try {
      await update();
      _updating = false;
      notifyListeners();
    } finally {
      if (_updating) {
        _updating = false;
        _text = previous;
        notifyListeners();
      }
    }
  }
}
