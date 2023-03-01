import 'package:flemozi/intents/close_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class TopBar extends StatelessWidget with PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        windowManager.startDragging();
      },
      child: Container(
        height: 20,
        width: double.infinity,
        color: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 70,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              end: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    minimumSize: const Size(10, 10),
                  ),
                  onPressed: () =>
                      CloseWindowAction().invoke(const CloseWindowIntent()),
                  child: const Icon(Icons.close, size: 14),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(20);
}
