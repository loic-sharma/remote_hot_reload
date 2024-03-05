import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:remote_hot_reload/firebase_options.dart';

final rfw = RfwController();
final firebase = FirebaseWorker();

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

  Future<void> stageRfw(String staged) async {
    await rfw.update(staged, rfw.text, () async {
      await Future<void>.delayed(const Duration(seconds: 1));
    });
  }

  Future<void> deployRfw(String text) async {
    await rfw.update(rfw.staged, text, () async {
      await Future<void>.delayed(const Duration(seconds: 1));
    });
  }
}

class FirebaseWorker {
  DatabaseReference get _rfwTextRef => FirebaseDatabase.instance.ref("rfwText");
  DatabaseReference get _stagedRef => FirebaseDatabase.instance.ref("staged");

  Future<void> start() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Read the initial RFW text values.
    final rfwSnapshot = await _rfwTextRef.get();
    final stagedSnapshot = await _stagedRef.get();
    rfw.text = (rfwSnapshot.exists) ? rfwSnapshot.value.toString() : '';
    rfw.staged = (stagedSnapshot.exists) ? stagedSnapshot.value.toString() : '';

    // Listen for changes...
    _rfwTextRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      rfw.text = data.toString();
    });
    _stagedRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      rfw.staged = data.toString();
    });
  }

  Future<void> stageRfw(String staged) async {
    await rfw.update(staged, rfw.text, () async {
      await _stagedRef.set(staged);
    });
  }

  Future<void> deployRfw(String text) async {
    await rfw.update(text, text, () async {
      await _stagedRef.set(text);
      await _rfwTextRef.set(text);
    });
  }
}

abstract interface class RfwNotifier with ChangeNotifier {
  /// True if a deployment is underway.
  bool get updating;

  /// RFW text that's staged but not deployed yet.
  String get staged;

  /// RFW text that's deployed.
  String get text;
}

class RfwController with ChangeNotifier implements RfwNotifier {
  RfwController();

  @override
  bool get updating => _updating;
  bool _updating = true;

  @override
  String get staged => _staged;
  String _staged = '';
  set staged(String value) {
    _updating = false;
    _staged = value;
    notifyListeners();
  }

  @override
  String get text => _text;
  String _text = '';
  set text(String value) {
    _updating = false;
    _text = value;
    notifyListeners();
  }

  Future<void> update(
    String staged,
    String text,
    Future<void> Function() update,
  ) async {
    if (_updating) {
      throw 'Update already in progress!';
    }

    final previousStaged = _staged;
    final previousText = _text;
    _updating = true;
    _staged = staged;
    _text = text;
    notifyListeners();

    try {
      await update();
      _updating = false;
      notifyListeners();
    } finally {
      if (_updating) {
        _updating = false;
        _staged = previousStaged;
        _text = previousText;
        notifyListeners();
      }
    }
  }
}
