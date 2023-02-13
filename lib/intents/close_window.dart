import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CloseWindowIntent extends Intent {
  const CloseWindowIntent();
}

class CloseWindowAction extends Action<CloseWindowIntent> {
  @override
  void invoke(CloseWindowIntent intent) async {
    if (kDebugMode) {
      await windowManager.hide();
    } else {
      windowManager.close();
    }
  }
}
