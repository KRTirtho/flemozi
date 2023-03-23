import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:window_manager/window_manager.dart';

void useWindowListeners({
  VoidCallback? onWindowClose,
  VoidCallback? onWindowFocus,
  VoidCallback? onWindowBlur,
  VoidCallback? onWindowMaximize,
  VoidCallback? onWindowUnmaximize,
  VoidCallback? onWindowMinimize,
  VoidCallback? onWindowRestore,
  VoidCallback? onWindowResize,
  VoidCallback? onWindowResized,
  VoidCallback? onWindowMove,
  VoidCallback? onWindowMoved,
  VoidCallback? onWindowEnterFullScreen,
  VoidCallback? onWindowLeaveFullScreen,
  ValueChanged<String>? onWindowEvent,
}) {
  return use(
    UseWindowListeners(
      onWindowClose: onWindowClose,
      onWindowFocus: onWindowFocus,
      onWindowBlur: onWindowBlur,
      onWindowMaximize: onWindowMaximize,
      onWindowUnmaximize: onWindowUnmaximize,
      onWindowMinimize: onWindowMinimize,
      onWindowRestore: onWindowRestore,
      onWindowResize: onWindowResize,
      onWindowResized: onWindowResized,
      onWindowMove: onWindowMove,
      onWindowMoved: onWindowMoved,
      onWindowEnterFullScreen: onWindowEnterFullScreen,
      onWindowLeaveFullScreen: onWindowLeaveFullScreen,
      onWindowEvent: onWindowEvent,
    ),
  );
}

class UseWindowListeners extends Hook {
  final VoidCallback? onWindowClose;
  final VoidCallback? onWindowFocus;
  final VoidCallback? onWindowBlur;
  final VoidCallback? onWindowMaximize;
  final VoidCallback? onWindowUnmaximize;
  final VoidCallback? onWindowMinimize;
  final VoidCallback? onWindowRestore;
  final VoidCallback? onWindowResize;
  final VoidCallback? onWindowResized;
  final VoidCallback? onWindowMove;
  final VoidCallback? onWindowMoved;
  final VoidCallback? onWindowEnterFullScreen;
  final VoidCallback? onWindowLeaveFullScreen;
  final ValueChanged<String>? onWindowEvent;

  const UseWindowListeners({
    this.onWindowClose,
    this.onWindowFocus,
    this.onWindowBlur,
    this.onWindowMaximize,
    this.onWindowUnmaximize,
    this.onWindowMinimize,
    this.onWindowRestore,
    this.onWindowResize,
    this.onWindowResized,
    this.onWindowMove,
    this.onWindowMoved,
    this.onWindowEnterFullScreen,
    this.onWindowLeaveFullScreen,
    this.onWindowEvent,
  });

  @override
  _UseWindowListenersState createState() => _UseWindowListenersState();
}

class _UseWindowListenersState extends HookState<void, UseWindowListeners>
    implements WindowListener {
  @override
  void initHook() {
    super.initHook();
    WindowManager.instance.addListener(this);
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    super.dispose();
  }

  @override
  void build(BuildContext context) {}

  @override
  void onWindowBlur() {
    hook.onWindowBlur?.call();
  }

  @override
  void onWindowClose() {
    hook.onWindowClose?.call();
  }

  @override
  void onWindowEnterFullScreen() {
    hook.onWindowEnterFullScreen?.call();
  }

  @override
  void onWindowEvent(String eventName) {
    hook.onWindowEvent?.call(eventName);
  }

  @override
  void onWindowFocus() {
    hook.onWindowFocus?.call();
  }

  @override
  void onWindowLeaveFullScreen() {
    hook.onWindowLeaveFullScreen?.call();
  }

  @override
  void onWindowMaximize() {
    hook.onWindowMaximize?.call();
  }

  @override
  void onWindowMinimize() {
    hook.onWindowMinimize?.call();
  }

  @override
  void onWindowMove() {
    hook.onWindowMove?.call();
  }

  @override
  void onWindowMoved() {
    hook.onWindowMoved?.call();
  }

  @override
  void onWindowResize() {
    hook.onWindowResize?.call();
  }

  @override
  void onWindowResized() {
    hook.onWindowResized?.call();
  }

  @override
  void onWindowRestore() {
    hook.onWindowRestore?.call();
  }

  @override
  void onWindowUnmaximize() {
    hook.onWindowUnmaximize?.call();
  }
}
