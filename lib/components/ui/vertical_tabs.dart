import 'package:collection/collection.dart';
import 'package:flemozi/pages/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

final tabsIndex = StateProvider<int>((ref) => 0);

class VerticalTabs extends HookConsumerWidget {
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
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
    final controllerHook = useTabController(initialLength: tabs.length);

    final controller = this.controller ?? controllerHook;

    final activeIndex = ref.watch(tabsIndex);

    useEffect(() {
      void listener() {
        ref.read(tabsIndex.notifier).state = controller.index;
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
                    final active = activeIndex == index;
                    final radius = active
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          )
                        : BorderRadius.circular(8);
                    return Container(
                      decoration: BoxDecoration(
                        color: active ? theme.cardColor.withOpacity(.5) : null,
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
                        child: DefaultTextStyle(
                          style: theme.textTheme.bodyLarge!.copyWith(
                            color: active
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodyLarge?.color,
                            fontWeight: active
                                ? FontWeight.bold
                                : theme.textTheme.bodyLarge?.fontWeight,
                          ),
                          child: IconTheme(
                            data: theme.iconTheme.copyWith(
                              color: active
                                  ? theme.colorScheme.primary
                                  : theme.iconTheme.color,
                            ),
                            child: tab,
                          ),
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
                      backgroundColor: theme.cardColor.withOpacity(.5),
                      foregroundColor: theme.colorScheme.primary,
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
                color: theme.cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(8),
                  bottomRight: const Radius.circular(8),
                  topLeft:
                      activeIndex > 0 ? const Radius.circular(8) : Radius.zero,
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
                child: children[activeIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
