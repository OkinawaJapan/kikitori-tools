#!/bin/sh
# Build the Mac helper tools Kikitori downloads on first launch: an LGPL ffmpeg/ffprobe and whisper-cli, arm64.
# Output: dist-tools/ffmpeg-macos-arm64.zip, whisper-cpp-macos-arm64.zip, SHA256SUMS. Needs: Xcode command-line tools, cmake, nasm (brew).
# Licences: whisper.cpp MIT; ffmpeg LGPL-2.1+ (NO --enable-gpl / --enable-nonfree, so no libx264; H.264 comes from VideoToolbox);
# LAME is LGPL. Each zip carries the licence texts and BUILD-INFO.txt (versions + configure flags), and the sources are at the URLs below.
set -e
FFMPEG=9.0.2; WHISPER=v1.9.5; LAME=3.100
cd "$(dirname "$0")/../.."; ROOT=$PWD; W=$ROOT/build/tools; OUT=$ROOT/dist-tools; P=$W/prefix
export MACOSX_DEPLOYMENT_TARGET=12.0
rm -rf "$W" "$OUT"; mkdir -p "$W" "$OUT"; cd "$W"

curl -fsSL "https://downloads.sourceforge.net/project/lame/lame/$LAME/lame-$LAME.tar.gz" | tar xz
(cd lame-$LAME && ./configure --prefix="$P" --disable-shared --enable-static --disable-frontend --disable-decoder >/dev/null && make -j8 >/dev/null && make install >/dev/null)

curl -fsSL "https://ffmpeg.org/releases/ffmpeg-$FFMPEG.tar.xz" | tar xJ
(cd ffmpeg-$FFMPEG && CFG="--prefix=$P/ff --disable-gpl --disable-nonfree --disable-doc --disable-ffplay --enable-libmp3lame --enable-videotoolbox --enable-audiotoolbox --disable-autodetect --enable-zlib --enable-iconv --extra-libs=-liconv --extra-cflags=-I$P/include --extra-ldflags=-L$P/lib --pkg-config-flags=--static"
  ./configure $CFG >/dev/null && make -j8 >/dev/null && make install >/dev/null && echo "ffmpeg $FFMPEG configure: $CFG" > "$W/ffmpeg-info")  # && not ;: a failed build must stop here, not zip an empty folder
[ -x $P/ff/bin/ffmpeg ] && [ -x $P/ff/bin/ffprobe ] || { echo "ffmpeg build failed"; exit 1; }
mkdir -p pk-ff && cp $P/ff/bin/ffmpeg $P/ff/bin/ffprobe pk-ff/ && cp ffmpeg-$FFMPEG/COPYING.LGPLv2.1 pk-ff/ && cp lame-$LAME/COPYING pk-ff/COPYING.LAME
{ cat ffmpeg-info; echo "lame $LAME (LGPL) static"; echo "source: https://ffmpeg.org/releases/ffmpeg-$FFMPEG.tar.xz  https://lame.sourceforge.io/"; echo "built $(date -u +%F) on $(sw_vers -productVersion), arm64"; } > pk-ff/BUILD-INFO.txt
ffmpeg_ok=$(pk-ff/ffmpeg -hide_banner -version | grep -c -- "--enable-gpl" || true); [ "$ffmpeg_ok" = 0 ] || { echo "GPL build, refusing"; exit 1; }
(cd pk-ff && zip -qr "$OUT/ffmpeg-macos-arm64.zip" .)

git clone -q --depth 1 --branch $WHISPER https://github.com/ggml-org/whisper.cpp.git whisper
(cd whisper && cmake -B b -DBUILD_SHARED_LIBS=OFF -DGGML_METAL=ON -DGGML_METAL_EMBED_LIBRARY=ON -DWHISPER_BUILD_TESTS=OFF -DWHISPER_BUILD_EXAMPLES=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 >/dev/null && cmake --build b -j8 --target whisper-cli >/dev/null)
mkdir -p pk-wh && cp whisper/b/bin/whisper-cli pk-wh/ && cp whisper/LICENSE pk-wh/LICENSE
echo "whisper.cpp $WHISPER (MIT), Metal GPU, static. source: https://github.com/ggml-org/whisper.cpp/tree/$WHISPER  built $(date -u +%F), arm64" > pk-wh/BUILD-INFO.txt
(cd pk-wh && zip -qr "$OUT/whisper-cpp-macos-arm64.zip" .)

cd "$OUT" && shasum -a 256 *.zip | tee SHA256SUMS; ls -lh
otool -L "$W/pk-ff/ffmpeg" "$W/pk-wh/whisper-cli" | grep -v "^/" | grep -v "/usr/lib\|/System" || true
