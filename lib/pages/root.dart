import 'package:flemozi/components/root/emoji.dart';
import 'package:flemozi/intents/close_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:window_manager/window_manager.dart';

class RootPage extends HookWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: GestureDetector(
            onHorizontalDragStart: (details) {
              windowManager.startDragging();
            },
            onSecondaryTap: () {
              windowManager.popUpWindowMenu();
            },
            child: Row(
              children: [
                const Expanded(
                  child: TabBar(
                    padding: EdgeInsets.all(10),
                    tabs: [
                      Tab(text: "Emoji"),
                      Tab(text: "GIF"),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  margin: const EdgeInsets.only(top: 10),
                  child: FilledButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    onPressed: () {
                      Actions.invoke(context, const CloseWindowIntent());
                    },
                    child: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: TabBarView(
            children: [
              Emoji(),
              Center(child: Text("GIF")),
            ],
          ),
        ),
      ),
    );
  }
}
