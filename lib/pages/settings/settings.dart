import 'package:flemozi/components/ui/top_bar.dart';
import 'package:flemozi/hooks/use_force_updater.dart';
import 'package:flemozi/pages/settings/about.dart';
import 'package:flemozi/pages/settings/keyboard_shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const TopBar(),
      body: ListTileTheme(
        dense: true,
        tileColor: Theme.of(context).colorScheme.onSecondary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            HookBuilder(
              builder: (context) {
                final update = useForceUpdater();
                final snapshot = useFuture(launchAtStartup.isEnabled());
                return SwitchListTile(
                  secondary: const Icon(Icons.power_settings_new),
                  title: const Text('Launch at startup'),
                  value: snapshot.data ?? false,
                  onChanged: !snapshot.hasData
                      ? null
                      : (value) async {
                          if (value) {
                            await launchAtStartup.enable();
                          } else {
                            await launchAtStartup.disable();
                          }
                          update();
                        },
                );
              },
            ),
            const SizedBox(height: 5),
            ListTile(
              title: const Text('Keyboard shortcuts'),
              leading: const Icon(Icons.keyboard_rounded),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const KeyboardShortcutsPage(),
                ));
              },
            ),
            const SizedBox(height: 5),
            ListTile(
              title: const Text('About'),
              leading: const Icon(Icons.info),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const About(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
