INNO_VERSION=6.2.0
TEMP_DIR=/tmp/flemozi-tar
USR_SHARE=deb-struct/usr/share
BUNDLE_DIR=build/linux/x64/release/bundle
MIRRORLIST=${PWD}/build/mirrorlist

tar:
		mkdir -p $(TEMP_DIR)\
		&& cp -r $(BUNDLE_DIR)/* $(TEMP_DIR)\
		&& cp linux/flemozi.desktop $(TEMP_DIR)\
		&& cp assets/logo.png $(TEMP_DIR)\
		&& tar -cJf build/Flemozi-linux-x86_64.tar.xz -C $(TEMP_DIR) .\
		&& rm -rf $(TEMP_DIR)

aursrcinfo:
					 docker run -e EXPORT_SRC=1 -v ${PWD}/aur-struct:/pkg -v ${MIRRORLIST}:/etc/pacman.d/mirrorlist:ro whynothugo/makepkg

publishaur: 
					 echo '[Warning!]: you need SSH paired with AUR'\
					 && rm -rf build/flemozi\
					 && git clone ssh://aur@aur.archlinux.org/flemozi-bin.git build/flemozi\
					 && cp aur-struct/PKGBUILD aur-struct/.SRCINFO build/flemozi\
					 && cd build/flemozi\
					 && git add .\
					 && git commit -m "${MSG}"\
					 && git push

innoinstall:
						powershell curl -o build\installer.exe http://files.jrsoftware.org/is/6/innosetup-${INNO_VERSION}.exe
		 				powershell build\installer.exe /verysilent /allusers /dir=build\iscc

inno:
		 powershell .\build\iscc\iscc.exe scripts\windows-setup-creator.iss

choco:
			powershell cp dist\Spotube-windows-x86_64-setup.exe choco-struct\tools
			powershell choco pack .\choco-struct\spotube.nuspec  --outputdirectory dist

gensums:
				sh -c scripts/gensums.sh