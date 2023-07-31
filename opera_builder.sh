#!/bin/bash
# Based on: https://github.com/ivan-hc/Opera-appimage
#
set -x

# DOWNLOAD EXTRA-LIBS
#mkdir -p lib_extra/tmp/
#cd lib_extra/tmp/

#wget $(wget -q https://api.github.com/repos/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt/releases/latest -O - | grep browser_download_url | grep -i linux | grep -i 64 | cut -d '"' -f 4 | head -1)
#unzip *.zip

#cd ../
#mv ./tmp/libffmpeg.so ./libffmpeg.so

#mkdir tmp2/
#cd tmp2/
#wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#ar x *.deb
#tar xf data.tar.xz
#cd ../
#mv tmp2/opt/google/chrome/WidevineCdm/_platform_specific/linux_x64/libwidevinecdm.so libwidevinecdm.so

#rm -R -f tmp*
#chmod a+x *.so

#cd ../

# CREATE OPERA STABLE APPIMAGE
mkdir tmp/
cp -r lib_extra/ tmp/
cd tmp/
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$(uname -m).AppImage -O appimagetool
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage

version_deb=$(wget -q https://deb.opera.com/opera-stable/pool/non-free/o/opera-stable/ -O - | grep deb | tail -1 | grep -o -P '(?<=.deb">).*(?=</a>)')
wget "https://deb.opera.com/opera-stable/pool/non-free/o/opera-stable/$version_deb"
ar x *.deb
tar xf data.tar.xz
mkdir opera.AppDir
mv usr/lib/x86_64-linux-gnu/opera/* opera.AppDir/
mv usr/share/applications/*.desktop opera.AppDir/
sed -i -e '/TargetEnvironment/d' opera.AppDir/*.desktop
mv usr/share/pixmaps/* opera.AppDir/
tar xf control.tar.xz
VERSION=$(cat control | grep -i version | cut -c 10-)

cat >> opera.AppDir/AppRun << 'EOF'
#!/bin/sh
APP=opera
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
export LD_LIBRARY_PATH=/lib/:/lib64/:/lib/x86_64-linux-gnu/:/usr/lib/:"${HERE}"/lib_extra/:LD_LIBRARY_PATH
exec "${HERE}"/opera "$@"
EOF
chmod +x opera.AppDir/AppRun

mv lib_extra opera.AppDir/

ARCH=x86_64 ./appimagetool-x86_64.AppImage -n opera.AppDir/

pwd
ls -lah
cd ..
mv tmp/*AppImage Opera-"$VERSION"-x86_64.AppImage
