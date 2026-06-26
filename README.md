<p align="center"><img width="200" src="assets/logo.png"></p>
<h1 align="center">Flemozi</h1>

<p align="center">
    A simple✨, fast⚡ and lightweight🪶 emoji picker for desktop operating systems🫶
    <br>
    Available for Linux🐧, Windows🪟 and macOS🍎.
</p>

## Highlights🚀

- Not Electron based🙃
- Configurable Global🪩 shortcut🩳✂️ to open the emoji picker
- Launches on system startup, runs in the background and can invoked from anywhere👻
- Supports GIFs📼, stickers🎟️ and ASCII emojis👴 too
- Copies the selected emoji to the clipboard📋 and automatically closes the picker obviously🤦‍♂️

## Installation📦

<!-- Table listing all the available downloads -->

| Linux                                                                   | Windows                                                       | macOS                                               |
| ----------------------------------------------------------------------- | ------------------------------------------------------------- | --------------------------------------------------- |
| [AppImage⚙️][AppImage]                                                   | [exe🪟][exe]                                                   | [DMG💿][dmg]                                         |
| [Debian🍥/Ubuntu⭕][deb]                                                | WinGet🪟🌈 <br>`winget install KRTirtho.flemozi` | Homebrew🍺 (Soon)<!-- <br>`brew install flemozi` --> |
| [Fedora🎩/OpenSuse🦎][rpm]                                              | Chocolatey🍫 (Soon)<!-- <br>`choco install flemozi`  -->       |                                                     |
| [Tarball][tar]                                                          |                                                               |                                                     |
| [Flatpak📦][Flatpak] <br>`flatpak install dev.krtirtho.Flemozi`                    |                                                               |                                                     |
| [AUR🌁][AUR] <br>`yay -S flemozi`                                       |                                                               |                                                     |

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

- Rust 1.85+ (edition 2024)

#### Building🏗️

```bash
$ git clone https://github.com/KRTirtho/flemozi.git
$ cd flemozi
$ cargo build --release
```

Twemoji PNGs must exist in `assets/twemoji/` for the build-time codegen step.

Built with [Iced](https://iced.rs/), a cross-platform GUI library for Rust.

## Credits🙇

- Kingkor Roy Tirtho (Developer) [@KRTirtho](https://github.com/KRTirtho)

## Acknowledgements🙏

- [Twitter Emoji (Twemoji)](https://twemoji.twitter.com/)


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
[AUR]: https://aur.archlinux.org/packages/flemozi
[Flatpak]: https://flathub.org/apps/dev.krtirtho.Flemozi
