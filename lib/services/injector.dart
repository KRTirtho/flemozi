import 'package:flemozi/src/rust/api/injector.dart';

abstract final class Injector {
  static Future<void> injectEmojiNative(String emoji, {required int targetHwndRaw}) async {
    return injectEmoji(emoji: emoji, targetHwndRaw: targetHwndRaw);
  }
}
