import 'package:flutter/material.dart';

class OverlayController extends ChangeNotifier {
  static final OverlayController instance = OverlayController._internal();
  OverlayController._internal();

  final List<VoidCallback> _registerCallbacks = [];

  void register(VoidCallback hideCallback) {
    _registerCallbacks.add(hideCallback);
  }

    /// Désenregistre une callback (utile quand le widget se démonte)
  void unregister(VoidCallback hideCallback) {
    _registerCallbacks.remove(hideCallback);
  }

  void hideAllExcept(VoidCallback except) {
    for (var callback in _registerCallbacks) {
      if (callback != except) callback();
    }
  }
}
