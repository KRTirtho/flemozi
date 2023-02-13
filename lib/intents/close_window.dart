import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CloseWindowIntent extends Intent {
  const CloseWindowIntent();
}

class CloseWindowAction extends Action<CloseWindowIntent> {
  @override
  void invoke(CloseWindowIntent intent) async {
    await windowManager.hide();
  }
}
