import 'package:flemozi/collections/twemoji_regex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore_for_file: prefer_final_locals

final _u200D = String.fromCharCode(0x200D);

final _uFE0Fg = RegExp(
  r'\uFE0F',
  unicode: true,
);

/// Converts emoji to unicode 😀 => "1F600"
String emojiToUnicode(String rawText) => _toCodePoint(
      !rawText.contains(_u200D) ? rawText.replaceAll(_uFE0Fg, '') : rawText,
    );

String _toCodePoint(String input, {String sep = '-'}) {
  var r = [], c = 0, p = 0, i = 0;
  while (i < input.length) {
    c = input.codeUnitAt(i++);
    if (p != 0) {
      r.add((0x10000 + ((p - 0xD800) << 10) + (c - 0xDC00)).toRadixString(16));
      p = 0;
    } else if (0xD800 <= c && c <= 0xDBFF) {
      p = c;
    } else {
      r.add(c.toRadixString(16));
    }
  }
  return r.join(sep);
}

class Twemoji extends HookWidget {
  const Twemoji({
    Key? key,
    required this.emoji,
    this.height = 30,
    this.width = 30,
    this.fit,
  }) : super(key: key);

  final String emoji;
  final double? height;
  final double? width;

  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final unicode = useMemoized(() {
      var cleanEmoji = '';
      emoji.splitMapJoin(
        regex,
        onMatch: (m) => cleanEmoji = m.input.substring(m.start, m.end),
      );
      return emojiToUnicode(cleanEmoji);
    }, [emoji]);

    if (unicode == '') {
      return Text(
        emoji,
        style: GoogleFonts.notoColorEmoji(fontSize: 24),
      );
    }
    return Image.asset(
      'assets/twemoji/$unicode.png',
      fit: fit,
      height: height,
      width: width,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          emoji,
          style: GoogleFonts.notoColorEmoji(fontSize: 24),
        );
      },
    );
  }
}
