import 'dart:convert';

import 'package:flemozi/collections/shortcuts.dart';
import 'package:flemozi/models/shortcut_def.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferencesProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

abstract class PreferencesService {
  Map<FlemoziShortcuts, FlemoziShortcutDef>? getShortcuts();
  Future<void> setShortcuts(
    Map<FlemoziShortcuts, FlemoziShortcutDef> shortcuts,
  );

  ({double width, double height})? getWindowSize();
  Future<void> setWindowSize(double width, double height);

  bool getShowWaylandDialog();
  Future<void> setShowWaylandDialog(bool value);
}

class SharedPreferencesService implements PreferencesService {
  final SharedPreferences _prefs;

  SharedPreferencesService(this._prefs);

  static Future<SharedPreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesService(prefs);
  }

  static const _shortcutsKey = 'shortcuts';
  static const _windowSizeKey = 'window_size';
  static const _showWaylandDialogKey = 'showWaylandDialog';

  @override
  Map<FlemoziShortcuts, FlemoziShortcutDef>? getShortcuts() {
    final raw = _prefs.getString(_shortcutsKey);
    if (raw == null) return null;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        FlemoziShortcuts.values[int.parse(key)],
        FlemoziShortcutDef.fromJson(
          Map.castFrom<dynamic, dynamic, String, dynamic>(value),
        ),
      ),
    );
  }

  @override
  Future<void> setShortcuts(
    Map<FlemoziShortcuts, FlemoziShortcutDef> shortcuts,
  ) async {
    final serialized = shortcuts.map(
      (key, value) => MapEntry(key.index.toString(), value.toJson()),
    );
    await _prefs.setString(_shortcutsKey, jsonEncode(serialized));
  }

  @override
  ({double width, double height})? getWindowSize() {
    final raw = _prefs.getString(_windowSizeKey);
    if (raw == null) return null;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (
      width: (decoded['width'] as num).toDouble(),
      height: (decoded['height'] as num).toDouble(),
    );
  }

  @override
  Future<void> setWindowSize(double width, double height) async {
    await _prefs.setString(
      _windowSizeKey,
      jsonEncode({'width': width, 'height': height}),
    );
  }

  @override
  bool getShowWaylandDialog() {
    return _prefs.getBool(_showWaylandDialogKey) ?? true;
  }

  @override
  Future<void> setShowWaylandDialog(bool value) async {
    await _prefs.setBool(_showWaylandDialogKey, value);
  }
}
