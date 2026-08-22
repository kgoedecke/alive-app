#!/bin/zsh
set -euo pipefail

repo_root="${0:A:h:h}"
source_svg="$repo_root/Assets/AppIcon.svg"
iconset_dir="$repo_root/.build/AppIcon.iconset"
output_file="$repo_root/Assets/AppIcon.icns"

if ! command -v magick >/dev/null 2>&1; then
  print -u2 "ImageMagick is required to regenerate the icon (brew install imagemagick)."
  exit 1
fi

if ! command -v rsvg-convert >/dev/null 2>&1; then
  print -u2 "librsvg is required to render the glass icon accurately (brew install librsvg)."
  exit 1
fi

mkdir -p "$iconset_dir"
master_png="$repo_root/.build/AppIcon-1024.png"
rsvg-convert -w 1024 -h 1024 -o "$master_png" "$source_svg"
magick "$master_png" -resize 16x16 "$iconset_dir/icon_16x16.png"
magick "$master_png" -resize 32x32 "$iconset_dir/icon_16x16@2x.png"
magick "$master_png" -resize 32x32 "$iconset_dir/icon_32x32.png"
magick "$master_png" -resize 64x64 "$iconset_dir/icon_32x32@2x.png"
magick "$master_png" -resize 128x128 "$iconset_dir/icon_128x128.png"
magick "$master_png" -resize 256x256 "$iconset_dir/icon_128x128@2x.png"
magick "$master_png" -resize 256x256 "$iconset_dir/icon_256x256.png"
magick "$master_png" -resize 512x512 "$iconset_dir/icon_256x256@2x.png"
magick "$master_png" -resize 512x512 "$iconset_dir/icon_512x512.png"
magick "$master_png" -resize 1024x1024 "$iconset_dir/icon_512x512@2x.png"
iconutil -c icns "$iconset_dir" -o "$output_file"
print "Created $output_file"
