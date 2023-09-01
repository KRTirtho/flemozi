import 'package:flutter/services.dart';

final Set<LogicalKeyboardKey> logicalKeys = {
  LogicalKeyboardKey.space,
  LogicalKeyboardKey.exclamation,
  LogicalKeyboardKey.quote,
  LogicalKeyboardKey.numberSign,
  LogicalKeyboardKey.dollar,
  LogicalKeyboardKey.percent,
  LogicalKeyboardKey.ampersand,
  LogicalKeyboardKey.quoteSingle,
  LogicalKeyboardKey.parenthesisLeft,
  LogicalKeyboardKey.parenthesisRight,
  LogicalKeyboardKey.asterisk,
  LogicalKeyboardKey.add,
  LogicalKeyboardKey.comma,
  LogicalKeyboardKey.minus,
  LogicalKeyboardKey.period,
  LogicalKeyboardKey.slash,
  LogicalKeyboardKey.digit0,
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
  LogicalKeyboardKey.colon,
  LogicalKeyboardKey.semicolon,
  LogicalKeyboardKey.less,
  LogicalKeyboardKey.equal,
  LogicalKeyboardKey.greater,
  LogicalKeyboardKey.question,
  LogicalKeyboardKey.at,
  LogicalKeyboardKey.bracketLeft,
  LogicalKeyboardKey.backslash,
  LogicalKeyboardKey.bracketRight,
  LogicalKeyboardKey.caret,
  LogicalKeyboardKey.underscore,
  LogicalKeyboardKey.backquote,
  LogicalKeyboardKey.keyA,
  LogicalKeyboardKey.keyB,
  LogicalKeyboardKey.keyC,
  LogicalKeyboardKey.keyD,
  LogicalKeyboardKey.keyE,
  LogicalKeyboardKey.keyF,
  LogicalKeyboardKey.keyG,
  LogicalKeyboardKey.keyH,
  LogicalKeyboardKey.keyI,
  LogicalKeyboardKey.keyJ,
  LogicalKeyboardKey.keyK,
  LogicalKeyboardKey.keyL,
  LogicalKeyboardKey.keyM,
  LogicalKeyboardKey.keyN,
  LogicalKeyboardKey.keyO,
  LogicalKeyboardKey.keyP,
  LogicalKeyboardKey.keyQ,
  LogicalKeyboardKey.keyR,
  LogicalKeyboardKey.keyS,
  LogicalKeyboardKey.keyT,
  LogicalKeyboardKey.keyU,
  LogicalKeyboardKey.keyV,
  LogicalKeyboardKey.keyW,
  LogicalKeyboardKey.keyX,
  LogicalKeyboardKey.keyY,
  LogicalKeyboardKey.keyZ,
  LogicalKeyboardKey.braceLeft,
  LogicalKeyboardKey.bar,
  LogicalKeyboardKey.braceRight,
  LogicalKeyboardKey.tilde,
  LogicalKeyboardKey.unidentified,
  LogicalKeyboardKey.backspace,
  LogicalKeyboardKey.tab,
  LogicalKeyboardKey.enter,
  LogicalKeyboardKey.escape,
  LogicalKeyboardKey.delete,
  LogicalKeyboardKey.capsLock,
  LogicalKeyboardKey.fn,
  LogicalKeyboardKey.fnLock,
  LogicalKeyboardKey.hyper,
  LogicalKeyboardKey.numLock,
  LogicalKeyboardKey.scrollLock,
  LogicalKeyboardKey.superKey,
  LogicalKeyboardKey.symbol,
  LogicalKeyboardKey.symbolLock,
  LogicalKeyboardKey.shiftLevel5,
  LogicalKeyboardKey.arrowDown,
  LogicalKeyboardKey.arrowLeft,
  LogicalKeyboardKey.arrowRight,
  LogicalKeyboardKey.arrowUp,
  LogicalKeyboardKey.end,
  LogicalKeyboardKey.home,
  LogicalKeyboardKey.pageDown,
  LogicalKeyboardKey.pageUp,
  LogicalKeyboardKey.insert,
  LogicalKeyboardKey.f1,
  LogicalKeyboardKey.f2,
  LogicalKeyboardKey.f3,
  LogicalKeyboardKey.f4,
  LogicalKeyboardKey.f5,
  LogicalKeyboardKey.f6,
  LogicalKeyboardKey.f7,
  LogicalKeyboardKey.f8,
  LogicalKeyboardKey.f9,
  LogicalKeyboardKey.f10,
  LogicalKeyboardKey.f11,
  LogicalKeyboardKey.f12,
  LogicalKeyboardKey.f13,
  LogicalKeyboardKey.f14,
  LogicalKeyboardKey.f15,
  LogicalKeyboardKey.f16,
  LogicalKeyboardKey.f17,
  LogicalKeyboardKey.f18,
  LogicalKeyboardKey.f19,
  LogicalKeyboardKey.f20,
  LogicalKeyboardKey.f21,
  LogicalKeyboardKey.f22,
  LogicalKeyboardKey.f23,
  LogicalKeyboardKey.f24,
  LogicalKeyboardKey.soft1,
  LogicalKeyboardKey.soft2,
  LogicalKeyboardKey.soft3,
  LogicalKeyboardKey.soft4,
  LogicalKeyboardKey.soft5,
  LogicalKeyboardKey.soft6,
  LogicalKeyboardKey.soft7,
  LogicalKeyboardKey.soft8,
  LogicalKeyboardKey.close,
  LogicalKeyboardKey.mailForward,
  LogicalKeyboardKey.mailReply,
  LogicalKeyboardKey.mailSend,
  LogicalKeyboardKey.mediaPlayPause,
  LogicalKeyboardKey.mediaStop,
  LogicalKeyboardKey.mediaTrackNext,
  LogicalKeyboardKey.mediaTrackPrevious,
  LogicalKeyboardKey.newKey,
  LogicalKeyboardKey.print,
  LogicalKeyboardKey.save,
  LogicalKeyboardKey.spellCheck,
  LogicalKeyboardKey.audioVolumeDown,
  LogicalKeyboardKey.audioVolumeUp,
  LogicalKeyboardKey.audioVolumeMute,
  LogicalKeyboardKey.key11,
  LogicalKeyboardKey.key12,
  LogicalKeyboardKey.suspend,
  LogicalKeyboardKey.resume,
  LogicalKeyboardKey.sleep,
  LogicalKeyboardKey.abort,
  LogicalKeyboardKey.intlBackslash,
  LogicalKeyboardKey.intlRo,
  LogicalKeyboardKey.intlYen,
  LogicalKeyboardKey.numpadEnter,
  LogicalKeyboardKey.numpadParenLeft,
  LogicalKeyboardKey.numpadParenRight,
  LogicalKeyboardKey.numpadMultiply,
  LogicalKeyboardKey.numpadAdd,
  LogicalKeyboardKey.numpadComma,
  LogicalKeyboardKey.numpadSubtract,
  LogicalKeyboardKey.numpadDecimal,
  LogicalKeyboardKey.numpadDivide,
  LogicalKeyboardKey.numpad0,
  LogicalKeyboardKey.numpad1,
  LogicalKeyboardKey.numpad2,
  LogicalKeyboardKey.numpad3,
  LogicalKeyboardKey.numpad4,
  LogicalKeyboardKey.numpad5,
  LogicalKeyboardKey.numpad6,
  LogicalKeyboardKey.numpad7,
  LogicalKeyboardKey.numpad8,
  LogicalKeyboardKey.numpad9,
  LogicalKeyboardKey.numpadEqual,
};

final logicalKeyListWithShift = {
  LogicalKeyboardKey.braceLeft,
  LogicalKeyboardKey.braceRight,
  LogicalKeyboardKey.tilde,
  LogicalKeyboardKey.unidentified,
  LogicalKeyboardKey.underscore,
  LogicalKeyboardKey.backquote,
  LogicalKeyboardKey.add,
  LogicalKeyboardKey.quote,
  LogicalKeyboardKey.question,
  LogicalKeyboardKey.at,
  LogicalKeyboardKey.colon,
  LogicalKeyboardKey.dollar,
  LogicalKeyboardKey.percent,
  LogicalKeyboardKey.ampersand,
  LogicalKeyboardKey.asterisk,
  LogicalKeyboardKey.parenthesisLeft,
  LogicalKeyboardKey.parenthesisRight,
};