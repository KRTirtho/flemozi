import 'package:flemozi/src/rust/api/injector.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NativeWindowInformationNotifier extends AsyncNotifier<CaretInfo> {
  static const _channel = MethodChannel('com.flemozi.app/native_window');

  @override
  build() async {
    final int nativeHwnd = await _channel.invokeMethod('getNativeWindowHandle');
    final stream = startCaretMonitor(flutterHwndRaw: nativeHwnd);

    final s = stream.listen((caretInfo) {
      if (state.value != caretInfo) {
        state = AsyncData(caretInfo);
      }
    });

    ref.onDispose(() {
      s.cancel();
    });

    return await stream.first;
  }
}

final nativeWindowInformationProvider =
    AsyncNotifierProvider<NativeWindowInformationNotifier, CaretInfo>(
      () => NativeWindowInformationNotifier(),
    );
