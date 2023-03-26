<p align="center"><img width="200" src="assets/logo.png"></p>
<h1 align="center">Flemozi</h1>

<p align="center">
    A simple✨, fast⚡ and lightweight🪶 emoji picker for desktop operating systems🫶
    <br>
    Available for Linux🐧, Windows🪟 and macOS🍎.
</p>

## Highlights🚀

- *Not Electron based🙃
- Configurable Global🪩 shortcut🩳✂️ to open the emoji picker
- Launches on system startup, runs in the background and can invoked from anywhere👻
- Supports GIFs📼, stickers🎟️ and ASCII emojis👴 too
- Copies the selected emoji to the clipboard📋 and automatically closes the picker obviously🤦‍♂️

## Installation📦

<!-- Table listing all the available downloads -->

| Linux                                                                   | Windows                                                       | macOS                                               |
| ----------------------------------------------------------------------- | ------------------------------------------------------------- | --------------------------------------------------- |
| [AppImage⚙️][AppImage]                                                   | [exe🪟][exe]                                                   | [DMG💿][dmg]                                         |
| [Debian🍥/Ubuntu⭕][deb]                                                  | WinGet🪟🌈 (Soon)<!-- <br>`winget install KRTirtho.flemozi` --> | Homebrew🍺 (Soon)<!-- <br>`brew install flemozi` --> |
| [Fedora🎩/OpenSuse🦎][rpm]                                                | Chocolatey🍫 (Soon)<!-- <br>`choco install flemozi`  -->       |                                                     |
| [Tarball][tar]                                                          |                                                               |                                                     |
| Flatpak📦 (Soon)<!-- <br>`flatpak install dev.krtirtho.Flemozi` -->      |                                                               |                                                     |
| AUR🌁 (Soon)<!-- <br>`yay -S flemozi`<br>or, `pamac install flemozi` --> |                                                               |                                                     |

## Sponsor☕💘

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/krtirtho)
<a href="https://patreon.com/krtirtho"><img src="https://user-images.githubusercontent.com/61944859/180249027-678b01b8-c336-451e-b147-6d84a5b9d0e7.png" width="250"/></a>

## Screenshots
![One](/assets/screenshots/one.png)
![Two](/assets/screenshots/two.png)
![Three](/assets/screenshots/three.png)

## Contributing🤝

Contributions are always welcome! Please read the [contribution guidelines](CONTRIBUTING.md) first.

## Building from source🛠️

#### Prerequisites📋

- Flutter SDK v3.7.0 or higher
- Rust v1.65.0 or higher
- Linux: keybinder3

#### Building🏗️

```bash
$ git clone https://github.com/KRTirtho/flemozi.git
$ cd flemozi
$ flutter pub get
$ flutter config --enable-<linux/windows/macos>-desktop
$ flutter build <linux/windows/macos>
```

**PS:** You can find the built binaries in `build/<linux/windows/macos>/<architecture>/release/bundle/`

## Credits🙇

- Kingkor Roy Tirtho (Developer) [@KRTirtho](https://github.com/KRTirtho)

## Acknowledgements🙏

- [Twitter Emoji](https://twemoji.twitter.com/)
- [Tenor](https://tenor.com/)
- [Giphy](https://giphy.com/)

### Libraries Credit📚
<details>
  <summary>Click to expand! (Reveal those gems💎)</summary>

  <ul>
    <li>
      <a href="https://github.com/Baseflow/flutter_cached_network_image">cached_network_image</a> - Flutter library to load and cache network images. Can also be used with placeholder and error widgets.
    </li>
    <li>
      <a href="https://pub.dev/packages/collection">collection</a> - Collections and utilities functions and classes related to collections.
    </li>
    <li>
      <a href="https://github.com/rrousselGit/flutter_hooks">flutter_hooks</a> - A flutter implementation of React hooks. It adds a new kind of widget with enhanced code reuse.
    </li>
    <li>
      <a href="https://github.com/sphericalkat/dart-fuzzywuzzy">fuzzywuzzy</a> - An implementation of the popular fuzzywuzzy package in Dart, to suit all your fuzzy string matching/searching needs!
    </li>
    <li>
      <a href="https://pub.dev/packages/google_fonts">google_fonts</a> - A Flutter package to use fonts from fonts.google.com. Supports HTTP fetching, caching, and asset bundling.
    </li>
    <li>
      <a href="https://riverpod.dev">hooks_riverpod</a> - A simple way to access state from anywhere in your application while robust and testable.
    </li>
    <li>
      <a href="https://pub.dev/packages/http">http</a> - A composable, multi-platform, Future-based API for HTTP requests.
    </li>
    <li>
      <a href="https://riverpod.dev">riverpod</a> - A simple way to access state from anywhere in your application while robust and testable.
    </li>
    <li>
      <a href="https://github.com/leanflutter/window_manager">window_manager</a> - This plugin allows Flutter desktop apps to resizing and repositioning the window.
    </li>
    <li>
      <a href="https://github.com/leanflutter/launch_at_startup">launch_at_startup</a> - This plugin allows Flutter desktop apps to Auto launch on startup / login.
    </li>
    <li>
      <a href="https://plus.fluttercommunity.dev/">package_info_plus</a> - Flutter plugin for querying information about the application package, such as CFBundleVersion on iOS or versionCode on Android.
    </li>
    <li>
      <a href="https://pub.dev/packages/shared_preferences">shared_preferences</a> - Flutter plugin for reading and writing simple key-value pairs. Wraps NSUserDefaults on iOS and SharedPreferences on Android.
    </li>
    <li>
      <a href="https://pub.dev/packages/alfred">alfred</a> - A performant, expressjs like web server / rest api framework thats easy to use and has all the bits in one place.
    </li>
    <li>
      <a href="https://pub.dev/packages/system_theme">system_theme</a> - A plugin to get the current system theme info. Supports Android, Web, Windows, Linux and macOS
    </li>
    <li>
      <a href="https://pub.dev/packages/flutter_svg">flutter_svg</a> - An SVG rendering and widget library for Flutter, which allows painting and displaying Scalable Vector Graphics 1.1 files.
    </li>
    <li>
      <a href="https://pub.dev/packages/url_launcher">url_launcher</a> - Flutter plugin for launching a URL. Supports web, phone, SMS, and email schemes.
    </li>
    <li>
      <a href="https://fl-query.vercel.app">fl_query</a> - Asynchronous data caching, refetching & invalidation library for Flutter
    </li>
    <li>
      <a href="https://fl-query.vercel.app">fl_query_hooks</a> - Elite flutter_hooks compatible library for fl_query, the Asynchronous data caching, refetching & invalidation library for Flutter
    </li>
    <li>
      <a href="https://github.com/java-james/giphy_client">giphy_api_client</a> - A Giphy API Client for Dart compatible Web, Flutter, and server-side dart
    </li>
    <li>
      <a href="https://github.com/java-james/flutter_dotenv">flutter_dotenv</a> - Easily configure any flutter application with global variables using a `.env` file.
    </li>
    <li>
      <a href="https://pub.dev/packages/json_annotation">json_annotation</a> - Classes and helper functions that support JSON code generation via the `json_serializable` package.
    </li>
    <li>
      <a href="https://pub.dev/packages/visibility_detector">visibility_detector</a> - A widget that detects the visibility of its child and notifies a callback.
    </li>
    <li>
      <a href="https://github.com/MixinNetwork/flutter-plugins/tree/main/packages/pasteboard">pasteboard</a> - A flutter plugin which could read image,files from clipboard and write files to clipboard.
    </li>
    <li>
      <a href="https://github.com/Baseflow/flutter_cache_manager/tree/master/flutter_cache_manager">flutter_cache_manager</a> - Generic cache manager for flutter. Saves web files on the storages of the device and saves the cache info using sqflite.
    </li>
    <li>
      <a href="https://github.com/superlistapp/super_native_extensions">super_clipboard</a> - Comprehensive clipboard access package for Flutter. Supports reading and writing of rich text, images and other formats.
    </li>
    <li>
      <a href="https://pub.dev/packages/path">path</a> - A string-based path manipulation library. All of the path operations you know and love, with solid support for Windows, POSIX (Linux and Mac OS X), and the web.
    </li>
    <li>
      <a href="https://github.com/magnuswikhog/easy_debounce">easy_debounce</a> - An extremely easy-to-use method call debouncer package for Dart/Flutter.
    </li>
    <li>
      <a href="https://github.com/Daegalus/dart-uuid">uuid</a> - RFC4122 (v1, v4, v5) UUID Generator and Parser for all Dart platforms (Web, VM, Flutter)
    </li>
    <li>
      <a href="https://github.com/hnvn/flutter_shimmer">shimmer</a> - A package provides an easy way to add shimmer effect in Flutter project
    </li>
    <li>
      <a href="https://github.com/hivedb/hive/tree/master/hive_flutter">hive_flutter</a> - Extension for Hive. Makes it easier to use Hive in Flutter apps.
    </li>
    <li>
      <a href="https://github.com/leisim/auto_size_text">auto_size_text</a> - Flutter widget that automatically resizes text to fit perfectly within its bounds.
    </li>
    <li>
      <a href="https://pub.dev/packages/path_provider">path_provider</a> - Flutter plugin for getting commonly used locations on host platform file systems, such as the temp and app data directories.
    </li>
    <li>
      <a href="https://pub.dev/packages/flutter_lints">flutter_lints</a> - Recommended lints for Flutter apps, packages, and plugins to encourage good coding practices.
    </li>
    <li>
      <a href="https://melos.invertase.dev">melos</a> - A tool for managing Dart & Flutter repositories with multiple packages (monorepo). Supports automated versioning via Conventional Commits. Inspired by JavaScripts Lerna package.
    </li>
    <li>
      <a href="https://pub.dev/packages/json_serializable">json_serializable</a> - Automatically generate code for converting to and from JSON by annotating Dart classes.
    </li>
    <li>
      <a href="https://pub.dev/packages/build_runner">build_runner</a> - A build system for Dart code generation and modular compilation.
    </li>
    <li>
      <a href="https://github.com/fluttercommunity/flutter_launcher_icons">flutter_launcher_icons</a> - A package which simplifies the task of updating your Flutter app's launcher icon.
    </li>
    <li>
      <a href="https://pub.dev/packages/html">html</a> - APIs for parsing and manipulating HTML content outside the browser.
    </li>
    <li>
      <a href="https://github.com/leoafarias/pub_api_client">pub_api_client</a> - An API Client for Pub to interact with public package information.
    </li>
    <li>
      <a href="https://github.com/google/flutter-desktop-embedding.git">window_size</a> - Allows resizing and repositioning the window containing Flutter.
    </li>
    <li>
      <a href="https://github.com/leanflutter/hotkey_manager">hotkey_manager</a> - This plugin allows Flutter desktop apps to defines system/inapp wide hotkey (i.e. shortcut).
    </li>
  </ul>
</details>


## License📜

This project is licensed under the [GPLv3](LICENSE) license.

<pre align="center">
  Copyright© 2023 Kingkor Roy Tirtho
</pre>

[AppImage]: https://github.com/KRTirtho/flemozi/releases/latest/download/Flemozi-linux-x86_64.AppImage
[tar]: https://github.com/KRTirtho/flemozi/releases/latest
[deb]: https://github.com/KRTirtho/flemozi/releases/latest/download/Flemozi-linux-x86_64.deb
[rpm]: https://github.com/KRTirtho/flemozi/releases/latest/download/Flemozi-linux-x86_64.rpm
[exe]: https://github.com/KRTirtho/flemozi/releases/latest/download/Flemozi-windows-x86_64-setup.exe
[dmg]: https://github.com/KRTirtho/flemozi/releases/latest/download/Flemozi-macos-universal.dmg