#!/bin/bash
# This script is modified from https://github.com/ivan-hc/Chrome-appimage/raw/fe079615eb4a4960af6440fc5961a66c953b0e2d/chrome-builder.sh

APP=CAJViewer

mkdir ./tmp
cd ./tmp || exit
wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$(uname -m).AppImage" -O appimagetool
chmod a+x ./appimagetool

# wget "${URL}"
cp ../*.deb .
ar x ./*.deb
tar xf ./data.tar.*
mkdir $APP.AppDir
mv ./opt/apps/cajviewer/* ./$APP.AppDir/

# Parse version
tar xf ./control.tar.*
VERSION="$(grep Version control | cut -c 10-)"
echo "$VERSION" > ../version.txt  # log version

# Generate desktop file
cat >> ./$APP.AppDir/$APP.desktop << EOF
[Desktop Entry]
Name=$APP
Type=Application
Comment=CAJViewer for Linux
Categories=Office;Documentation;
Exec=CAJViewer %f
Icon=cajviewer
MimeType=application/caj;application/kdh;application/nh;application/teb;application/pdf;
Terminal=false
X-AppImage-Version=$VERSION
EOF

# Generate AppRun
cat >> ./$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
APP=CAJViewer
HERE="$(dirname "$(readlink -f "${0}")")"
export LD_LIBRARY_PATH="${HERE}/lib:${LD_LIBRARY_PATH}"
export DYLD_FALLBACK_LIBRARY_PATH="${LD_LIBRARY_PATH}"
export QT_FONT_DPI=96
exec "${HERE}"/$APP "$@"
EOF
chmod a+x ./$APP.AppDir/AppRun


echo "Create a tarball"
cd ./$APP.AppDir || exit
tar cJvf ../"$APP-$VERSION-x86_64.tar.xz" .
cd ..
mv ./"$APP-$VERSION-x86_64.tar.xz" ..

echo "Create an AppImage"
ARCH=x86_64 ./appimagetool -n --verbose ./$APP.AppDir ../"$APP-$VERSION-x86_64.AppImage"
cd ..
rm -rf ./tmp
