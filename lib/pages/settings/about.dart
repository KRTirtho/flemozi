import 'package:flemozi/components/ui/top_bar.dart';
import 'package:flemozi/hooks/use_package_info.dart';
import 'package:flemozi/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class About extends HookConsumerWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final packageInfo = usePackageInfo();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const TopBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Image.asset(
                "assets/logo.png",
                height: 200,
                width: 200,
              ),
              Text(
                kIsLinux
                    ? "The missing emoji picker for Linux"
                    : "A powerful emoji picker",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 18),
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Founder:   Kingkor Roy Tirtho",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(width: 5),
                        CircleAvatar(
                          radius: 20,
                          child: ClipOval(
                            child: Image.network(
                              "https://avatars.githubusercontent.com/u/61944859?v=4",
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Version:              v${packageInfo.version}",
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: () {
                        launchUrlString(
                          "https://github.com/KRTirtho/flemozi",
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: const Text(
                        "Repository:        https://github.com/KRTirtho/flemozi",
                      ),
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: () {
                        launchUrlString(
                          "https://raw.githubusercontent.com/KRTirtho/flemozi/main/LICENSE",
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: const Text("License:               GPLv3"),
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: () {
                        launchUrlString(
                          "https://github.com/KRTirtho/flemozi/issues",
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: const Text(
                        "Bugs+Issues:     https://github.com/KRTirtho/flemozi/issues",
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                runSpacing: 20,
                spacing: 20,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(
                          Uri.parse("https://www.buymeacoffee.com/krtirtho"),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: SvgPicture.network(
                        "https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=krtirtho&button_colour=FF5F5F&font_colour=ffffff&font_family=Inter&outline_colour=000000&coffee_colour=FFDD00",
                        height: 45,
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(
                          Uri.parse("https://patreon.com/krtirtho"),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Image.network(
                        "https://user-images.githubusercontent.com/61944859/180249027-678b01b8-c336-451e-b147-6d84a5b9d0e7.png",
                        height: 45,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Flutter Rules. Hooks are best. Electron sucks :P",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
