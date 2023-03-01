import 'package:collection/collection.dart';
import 'package:flemozi/pages/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:window_manager/window_manager.dart';

class VerticalTabs extends HookWidget {
  final TabController? controller;

  final List<Widget> tabs;
  final List<Widget> children;
  const VerticalTabs({
    required this.tabs,
    required this.children,
    this.controller,
    super.key,
  }) : assert(
          tabs.length == children.length,
          'tabs and children must have the same length',
        );

  @override
  Widget build(BuildContext context) {
    final controllerHook = useTabController(initialLength: tabs.length);

    final controller = this.controller ?? controllerHook;

    final activeIndex = useState(0);

    useEffect(() {
      void listener() {
        activeIndex.value = controller.index;
      }

      controller.addListener(listener);
      return () {
        controller.removeListener(listener);
      };
    }, [controller]);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          GestureDetector(
            onHorizontalDragStart: (details) {
              windowManager.startDragging();
            },
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  ...tabs.mapIndexed((index, tab) {
                    final active = activeIndex.value == index;
                    final radius = active
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          )
                        : BorderRadius.circular(8);
                    return Container(
                      decoration: BoxDecoration(
                        color: active
                            ? Theme.of(context).cardColor.withOpacity(.5)
                            : null,
                        borderRadius: radius,
                      ),
                      width: 40,
                      height: 40,
                      child: MaterialButton(
                        onPressed: () {
                          controller.animateTo(index);
                        },
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: radius),
                        child: IconTheme(
                          data: Theme.of(context).iconTheme.copyWith(
                                color: active
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).iconTheme.color,
                              ),
                          child: tab,
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return const Settings();
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).cardColor.withOpacity(.5),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: const CircleBorder(),
                      minimumSize: const Size(20, 20),
                      padding: const EdgeInsets.all(0),
                    ),
                    child: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(8),
                  bottomRight: const Radius.circular(8),
                  topLeft: activeIndex.value > 0
                      ? const Radius.circular(8)
                      : Radius.zero,
                  bottomLeft: const Radius.circular(8),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: const Offset(0, 0),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: children[activeIndex.value],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
