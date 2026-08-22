#!/bin/zsh
set -euo pipefail

repo_root="${0:A:h:h}"
version="${1:-1.0.0}"
build_root="$repo_root/build"
app_path="$build_root/Alive.app"

cd "$repo_root"

architectures=(${=ALIVE_ARCHES:-$(uname -m)})
binaries=()
for architecture in $architectures; do
  triple="$architecture-apple-macosx13.0"
  swift build -c release --triple "$triple" --product Alive
  binaries+=("$(swift build -c release --triple "$triple" --show-bin-path)/Alive")
done

if [[ ! -f "$repo_root/Assets/AppIcon.icns" ]]; then
  print -u2 "Assets/AppIcon.icns is missing. Run scripts/make_icon.sh first."
  exit 1
fi

if [[ "$app_path" != "$repo_root"/build/Alive.app ]]; then
  print -u2 "Refusing to package to an unexpected path: $app_path"
  exit 1
fi

rm -rf "$app_path"
mkdir -p "$app_path/Contents/MacOS" "$app_path/Contents/Resources"
if (( ${#binaries} == 1 )); then
  cp "$binaries[1]" "$app_path/Contents/MacOS/Alive"
else
  lipo -create $binaries -output "$app_path/Contents/MacOS/Alive"
fi
cp "$repo_root/Resources/Info.plist" "$app_path/Contents/Info.plist"
cp "$repo_root/Assets/AppIcon.icns" "$app_path/Contents/Resources/AppIcon.icns"
plutil -replace CFBundleShortVersionString -string "$version" "$app_path/Contents/Info.plist"
plutil -replace CFBundleVersion -string "${GITHUB_RUN_NUMBER:-1}" "$app_path/Contents/Info.plist"

# Ad-hoc signing keeps the local bundle internally consistent. Release users can
# audit and build the app themselves; optional Developer ID signing is done in CI.
codesign --force --deep --sign - "$app_path"

print "Packaged $app_path"
