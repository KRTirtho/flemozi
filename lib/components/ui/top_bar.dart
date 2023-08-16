import 'package:flemozi/intents/close_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
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
        child: FilledButtonTheme(
          data: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              minimumSize: const Size(10, 10),
            ),
          ),
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
              if (Navigator.of(context).canPop())
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  start: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back, size: 14),
                    ),
                  ),
                ),
              Positioned.directional(
                textDirection: Directionality.of(context),
                end: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: FilledButton(
                    onPressed: () =>
                        CloseWindowAction().invoke(const CloseWindowIntent()),
                    child: const Icon(Icons.close, size: 14),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Size get preferredSize => const Size.fromHeight(20);
}
