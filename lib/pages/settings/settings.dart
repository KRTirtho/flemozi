import 'package:flemozi/components/ui/top_bar.dart';
import 'package:flemozi/pages/settings/about.dart';
import 'package:flutter/material.dart';

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
        horizontalTitleGap: 0,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
