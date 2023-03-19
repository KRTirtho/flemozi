import 'package:flemozi/components/root/emoji.dart';
import 'package:flemozi/components/root/gif.dart';
import 'package:flemozi/components/ui/top_bar.dart';
import 'package:flemozi/components/ui/vertical_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RootPage extends HookWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: VerticalTabs(
        tabs: const [
          Tooltip(
            message: 'Emoji',
            child: Icon(Icons.emoji_emotions),
          ),
          Tooltip(
            message: 'GIFs',
            child: Icon(Icons.gif_rounded),
          ),
        ],
        children: const [
          Emoji(),
          Gif(),
        ],
      ),
    );
  }
}
