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

mkdir -p "$iconset_dir"
magick -background none "$source_svg" -resize 16x16 "$iconset_dir/icon_16x16.png"
magick -background none "$source_svg" -resize 32x32 "$iconset_dir/icon_16x16@2x.png"
magick -background none "$source_svg" -resize 32x32 "$iconset_dir/icon_32x32.png"
magick -background none "$source_svg" -resize 64x64 "$iconset_dir/icon_32x32@2x.png"
magick -background none "$source_svg" -resize 128x128 "$iconset_dir/icon_128x128.png"
magick -background none "$source_svg" -resize 256x256 "$iconset_dir/icon_128x128@2x.png"
magick -background none "$source_svg" -resize 256x256 "$iconset_dir/icon_256x256.png"
magick -background none "$source_svg" -resize 512x512 "$iconset_dir/icon_256x256@2x.png"
magick -background none "$source_svg" -resize 512x512 "$iconset_dir/icon_512x512.png"
magick -background none "$source_svg" -resize 1024x1024 "$iconset_dir/icon_512x512@2x.png"
iconutil -c icns "$iconset_dir" -o "$output_file"
print "Created $output_file"
