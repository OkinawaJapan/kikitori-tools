# kikitori-tools

Helper tools that [Kikitori](https://github.com/OkinawaJapan/kikitori) downloads on Apple Silicon Macs without Homebrew (Settings › Status › Download). Kikitori checks each zip's SHA-256 before unpacking it.

| File | Contents | Licence |
|---|---|---|
| `ffmpeg-macos-arm64.zip` | `ffmpeg`, `ffprobe` 9.0.2, static, with LAME 3.100 (MP3) | LGPL-2.1-or-later (`COPYING.LGPLv2.1`, `COPYING.LAME` inside) |
| `whisper-cpp-macos-arm64.zip` | `whisper-cli` v1.9.5, Metal GPU, static | MIT (`LICENSE` inside) |

**LGPL notice.** This ffmpeg is built with `--disable-gpl --disable-nonfree`, so it contains no GPL or non-free code (no libx264; H.264 encoding uses Apple VideoToolbox). FFmpeg and LAME are free software under the GNU Lesser General Public License 2.1 or later, provided WITHOUT ANY WARRANTY. Corresponding source: https://ffmpeg.org/releases/ffmpeg-9.0.2.tar.xz and https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz. The exact configure flags are in each zip's `BUILD-INFO.txt`, and `build.sh` (attached) rebuilds both zips from those sources, so you can rebuild or replace any part of them. FFmpeg is a trademark of Fabrice Bellard; this build is not affiliated with the FFmpeg project.

**SHA-256**
```
9dad5348a705e255f619d1018ea3e2b7501ba8a91bfc9d6e53020852addfe643  ffmpeg-macos-arm64.zip
7a4aeb1bea9e2fdb7055943f07b34f7fa5db4213cc1313d8f4c28bf583bda493  whisper-cpp-macos-arm64.zip
```
