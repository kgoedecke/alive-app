#!/bin/zsh
set -euo pipefail

repo_root="${0:A:h:h}"
version="${1:-1.0.0}"
archive_path="$repo_root/build/Alive.zip"

"$repo_root/scripts/package_app.sh" "$version"
rm -f "$archive_path"
ditto -c -k --sequesterRsrc --keepParent "$repo_root/build/Alive.app" "$archive_path"
print "Created $archive_path"
